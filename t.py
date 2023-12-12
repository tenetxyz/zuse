import os
import subprocess
import sys

cur_directory = os.path.dirname(os.path.abspath(__file__))

def run_example(path, extra_cmd=None):
    command = f"cd examples/{path} && yarn run dev"
    if extra_cmd:
        command += f" && {extra_cmd}"
    print(command)
    subprocess.run(["yarn", "concurrently", "-n", path, "-c", "#fb8500", command])


def main():
    if len(sys.argv) < 2:
        print("Usage: ./t build|run [command]")
        return
    # print(sys.argv)

    try:
        if sys.argv[1] == "build":
            command1 = ["yarn", "run", "build"]
            subprocess.run(command1, env=os.environ.copy())

            example_dir = os.path.join("examples", sys.argv[2])
            os.chdir(example_dir)

            command2 = ["yarn", "run", "build"]
            subprocess.run(command2, env=os.environ.copy())

        if sys.argv[1] == "run":
            if sys.argv[2] == "dev":
                subcommands = ["./t run anvil", f"./t run framework {' '.join(sys.argv[3:])} && ./t run {sys.argv[3]} {' '.join(sys.argv[4:])}"]
                command = ["yarn", "concurrently", "-n", "anvil,contracts", "-c", "blue,green"] + subcommands
                # Copy the current environment and modify it
                env = os.environ.copy()
                env["NODE_ENV"] = "development"
                subprocess.run(command, env=env)

            if sys.argv[2] == "prod":
                subcommands = [f"./t run framework {' '.join(sys.argv[3:])} && ./t run {sys.argv[3]} {' '.join(sys.argv[4:])}"]
                command = ["yarn", "concurrently", "-n", "contracts", "-c", "green"] + subcommands
                env = os.environ.copy()
                env["NODE_ENV"] = "production"
                subprocess.run(command, env=env)

            elif sys.argv[2] == "anvil":
                os.chdir("scripts")
                subprocess.run(["yarn", "run", "anvil"])

            elif sys.argv[2] == "framework":
                if "--skip-build" in sys.argv:
                    subprocess.run(["yarn", "run", "registry"])
                else:
                    subprocess.run(["yarn", "run", "dev"])

            elif sys.argv[2] == "basic-world":
                run_example("basic-world")

            elif sys.argv[2] == "everlon":
                extra_cmd = []

                if "--with-extensions" in sys.argv:
                    extra_cmd.append("yarn run deploy:extensions")
                if "--with-pretty" in sys.argv:
                    extra_cmd.append("yarn run deploy:pretty")
                if "--with-derived" in sys.argv:
                    extra_cmd.append("yarn run deploy:derived")
                if "--snapshot" in sys.argv:
                    extra_cmd.append(f"sh {cur_directory}/scripts/rollback/create_snapshot.sh")

                # Join the commands with ' && '
                command_str = " && ".join(extra_cmd)

                run_example("everlon", command_str)

            elif sys.argv[2] == "snapshot":
                subprocess.run([f"sh {cur_directory}/scripts/rollback/create_snapshot.sh"])
                print("created snapshot")

            else:
                print("Invalid command: " + sys.argv[2])
    except KeyboardInterrupt:
        print("\nInterrupted by user. Exiting...")
        sys.exit(1)

if __name__ == "__main__":
    main()
