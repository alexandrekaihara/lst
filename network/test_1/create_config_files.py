from sys import argv

# Brief: Class responsible for configuring all experiment setup, create docker-compose file to setup containers,
class CreateDockerCompose():
    def __init__(self, configfile) -> None:


def main():
    try:
        CreateDockerCompose(argv[1])
    except:
        print("Syntax")

if __name__ == "__main__":
    main()