def _verilator_impl(ctx):
    obj_dir = ctx.actions.declare_file(ctx.label.name)
    executable = ctx.actions.declare_file(ctx.attr.top_module)

    args = []
    args += ctx.attr.arguments
    args += ["--top-module", ctx.attr.top_module]
    args += [src.path for src in ctx.files.srcs]
    args += ["--Mdir", obj_dir.basename]

    ctx.actions.run_shell(
        outputs = [obj_dir, executable],
        inputs = ctx.files.srcs + ctx.files.hdrs,
        command = "verilator %s && \
                    make -j -C %s -f Vpicorv32_wrapper.mk && \
                    cp -r %s %s && \
                    cp %s/Vpicorv32_wrapper %s" % (" ".join(args), obj_dir.basename, obj_dir.basename, obj_dir.path, obj_dir.basename, executable.path),
        use_default_shell_env = True,
    )

    runfiles = ctx.runfiles(files = [obj_dir] + ctx.files.data)
    return [DefaultInfo(executable = executable, runfiles = runfiles)]

verilator = rule(
    implementation = _verilator_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = ["v", "sv", "c", "cc", "cpp"],
        ),
        "hdrs": attr.label_list(
            allow_files = ["h", "hpp"],
        ),
        "arguments": attr.string_list(),
        "top_module": attr.string(),
        "data": attr.label_list(
            allow_files = True,
        ),
    },
    executable = True,
)