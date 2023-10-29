import os
import subprocess
import sys

cur_directory = os.path.dirname(os.path.abspath(__file__))

def run_example(path, extra_cmd=None):
    command = f"cd examples/{path} && yarn run dev"
    if extra_cmd:
        command += f"&& {extra_cmd}"
    print(command)
    subprocess.run(["yarn", "concurrently", "-n", "example", "-c", "#fb8500", command])


def main():
    if len(sys.argv) < 2:
        print("Usage: ./t run [command]")
        return
    # print(sys.argv)

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

        elif sys.argv[2] == "basic-conserved-world":
            extra_cmd = []

            if "--with-pokemon" in sys.argv:
                extra_cmd.append("yarn run deploy:pokemon")
            if "--with-extensions" in sys.argv:
                extra_cmd.append("yarn run deploy:extensions")
            if "--with-derived" in sys.argv:
                extra_cmd.append("yarn run deploy:derived")
            if "--snapshot" in sys.argv:
                extra_cmd.append(f"sh {cur_directory}/scripts/rollback/create_snapshot.sh")

            # Join the commands with ' && '
            command_str = " && ".join(extra_cmd)

            run_example("basic-conserved-world", command_str)

        elif sys.argv[2] == "multiple-layers-world":
            run_example("multiple-layers-world")

        elif sys.argv[2] == "snapshot":
            subprocess.run([f"sh {cur_directory}/scripts/rollback/create_snapshot.sh"])
            print("rollbacked snapshot")

        else:
            print("Invalid command.")

if __name__ == "__main__":
    main()
