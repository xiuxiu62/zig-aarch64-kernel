const std = @import("std");

pub fn build(b: *std.Build) void {
    // We need to use createTarget() to get a proper ResolvedTarget
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_model = .{ .explicit = &std.Target.aarch64.cpu.cortex_a53 },
    });

    const optimize = b.standardOptimizeOption(.{});
    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_source_file = .{ .cwd_relative = "src/kernel/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    kernel.addAssemblyFile(.{ .cwd_relative = "src/boot/main.s" });
    kernel.addAssemblyFile(.{ .cwd_relative = "src/boot/vectors.s" });

    kernel.setLinkerScriptPath(.{ .cwd_relative = "src/linker.ld" });
    kernel.pie = false;

    const kernel_binary_location =
        b.getInstallPath(.bin, "kernel");
    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "qemu-system-aarch64",  "-M",                           "virt",     "-cpu",                  "cortex-a53", "-m",                          "128M",    "-kernel",
        kernel_binary_location, "-nographic",                   "-chardev", "stdio,id=char0,mux=on", "-mon",       "chardev=char0,mode=readline", "-serial", "chardev:char0",
        "-d",                   "guest_errors,unimp,cpu_reset", "-D",       "zig-out/qemu.log",
    });
    run_cmd.step.dependOn(&kernel.step);

    const run_step = b.step("run", "Run the kernel in QEMU");
    run_step.dependOn(&run_cmd.step);

    b.installArtifact(kernel);
}
