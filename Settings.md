Varibles:
// SERVER_JARFILE = server.jar # No edit

# Sponge
// SPONGE_VERSION = 1.12.2-7.3.0

# Paper
// MINECRAFT_VERSION = latest
// BUILD_NUMBER = latest

# Forge
// BUILD_TYPE = recommended
// FORGE_VERSION = 1.12.2

# Bungeecord
// BUNGEE_VERSION = latest

# Java
// VANILLA_VERSION = latest

# Bedrock
BEDROCK_VERSION = latest
SERVERNAME = "An AFK Hosting Bedrock Server"
GAMEMODE = "survival"
DIFFICULTY = "easy"
CHEATS = "false"



{
    "sponge/server.properties": {
        "parser": "properties",
        "find": {
            "server-ip": "0.0.0.0",
            "server-port": "{{server.build.default.port}}",
            "query.port": "{{server.build.default.port}}"
        }
    },
    "sponge/eula.txt": {
        "parser": "properties",
        "find": {
            "eula": "true"
        }
    },
    "paper/server.properties": {
        "parser": "properties",
        "find": {
            "server-ip": "0.0.0.0",
            "server-port": "{{server.build.default.port}}",
            "query.port": "{{server.build.default.port}}"
        }
    },
    "paper/eula.txt": {
        "parser": "properties",
        "find": {
            "eula": "true"
        }
    },
    "forge/server.properties": {
        "parser": "properties",
        "find": {
            "server-ip": "0.0.0.0",
            "server-port": "{{server.build.default.port}}",
            "query.port": "{{server.build.default.port}}"
        }
    },
    "forge/eula.txt": {
        "parser": "properties",
        "find": {
            "eula": "true"
        }
    },
    "bungeecord/config.yml": {
        "parser": "yaml",
        "find": {
            "listeners[0].query_port": "{{server.build.default.port}}",
            "listeners[0].host": "0.0.0.0:{{server.build.default.port}}",
            "servers.*.address": {
                "regex:^(127\\.0\\.0\\.1|localhost)(:\\d{1,5})?$": "{{config.docker.interface}}$2"
            }
        }
    },
    "bungeecord/eula.txt": {
        "parser": "properties",
        "find": {
            "eula": "true"
        }
    },
    "java/server.properties": {
        "parser": "properties",
        "find": {
            "server-ip": "0.0.0.0",
            "server-port": "{{server.build.default.port}}",
            "query.port": "{{server.build.default.port}}"
        }
    },
    "java/eula.txt": {
        "parser": "properties",
        "find": {
            "eula": "true"
        }
    },
    "bedrock/server.properties": {
        "parser": "properties",
        "find": {
            "server-port": "{{server.build.default.port}}",
            "server-name": "{{server.build.env.SERVERNAME}}",
            "gamemode": "{{server.build.env.GAMEMODE}}",
            "difficulty": "{{server.build.env.DIFFICULTY}}",
            "allow-cheats": "{{server.build.env.CHEATS}}"
        }
    },
    "bedrock/eula.txt": {
        "parser": "properties",
        "find": {
            "eula": "true"
        }
    }
}