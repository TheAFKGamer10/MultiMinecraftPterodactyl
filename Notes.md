Sponge: ghcr.io/pterodactyl/installers:alpine
    ```shell
    #!/bin/ash
    # Sponge Installation Script
    #
    # Server Files: /mnt/server

    mkdir -p /mnt/server/sponge
    cd /mnt/server/sponge

    curl -sSL "https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/${SPONGE_VERSION}/spongevanilla-${SPONGE_VERSION}.jar" -o ${SERVER_JARFILE}
    ```
    Start: java -Xms128M -XX:MaxRAMPercentage=95.0 -jar {{SERVER_JARFILE}}
    Config:
        ```json
            {
                "server.properties": {
                    "parser": "properties",
                    "find": {
                        "server-ip": "0.0.0.0",
                        "server-port": "{{server.build.default.port}}",
                        "query.port": "{{server.build.default.port}}"
                    }
                }
            }
        ```
    StartConfig:
        ```json
            {
                "done": ")! For help, type "
            }
        ```

Paper: ghcr.io/pterodactyl/installers:alpine
    ```shell
    #!/bin/ash
    # Paper Installation Script
    #
    # Server Files: /mnt/server
    PROJECT=paper

    if [ -n "${DL_PATH}" ]; then
        echo -e "Using supplied download url: ${DL_PATH}"
        DOWNLOAD_URL=`eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
    else
        VER_EXISTS=`curl -s https://api.papermc.io/v2/projects/${PROJECT} | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep -m1 true`
        LATEST_VERSION=`curl -s https://api.papermc.io/v2/projects/${PROJECT} | jq -r '.versions' | jq -r '.[-1]'`

        if [ "${VER_EXISTS}" == "true" ]; then
            echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
        else
            echo -e "Specified version not found. Defaulting to the latest ${PROJECT} version"
            MINECRAFT_VERSION=${LATEST_VERSION}
        fi

        BUILD_EXISTS=`curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds[] | tostring | contains($BUILD)' | grep -m1 true`
        LATEST_BUILD=`curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[-1]'`

        if [ "${BUILD_EXISTS}" == "true" ]; then
            echo -e "Build is valid for version ${MINECRAFT_VERSION}. Using build ${BUILD_NUMBER}"
        else
            echo -e "Using the latest ${PROJECT} build for version ${MINECRAFT_VERSION}"
            BUILD_NUMBER=${LATEST_BUILD}
        fi

        JAR_NAME=${PROJECT}-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar

        echo "Version being downloaded"
        echo -e "MC Version: ${MINECRAFT_VERSION}"
        echo -e "Build: ${BUILD_NUMBER}"
        echo -e "JAR Name of Build: ${JAR_NAME}"
        DOWNLOAD_URL=https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}
    fi

    cd /mnt/server

    echo -e "Running curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

    if [ -f ${SERVER_JARFILE} ]; then
        mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
    fi

    curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

    if [ ! -f server.properties ]; then
        echo -e "Downloading MC server.properties"
        curl -o server.properties https://raw.githubusercontent.com/parkervcp/eggs/master/minecraft/java/server.properties
    fi
    ```
    Start: java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar {{SERVER_JARFILE}}
    Config:
        ```json
            {
                "server.properties": {
                    "parser": "properties",
                    "find": {
                        "server-ip": "0.0.0.0",
                        "server-port": "{{server.build.default.port}}",
                        "query.port": "{{server.build.default.port}}"
                    }
                }
            }
        ```
    StartConfig:
        ```json
            {
                "done": ")! For help, type "
            }
        ```

Forge: openjdk:8-jdk-slim
    ```shell
    #!/bin/bash
    # Forge Installation Script
    #
    # Server Files: /mnt/server
    apt update
    apt install -y curl jq

    if [[ ! -d /mnt/server ]]; then
      mkdir /mnt/server
    fi

    cd /mnt/server

    # Remove spaces from the version number to avoid issues with curl
    FORGE_VERSION="$(echo "$FORGE_VERSION" | tr -d ' ')"
    MC_VERSION="$(echo "$MC_VERSION" | tr -d ' ')"

    if [[ ! -z ${FORGE_VERSION} ]]; then
      DOWNLOAD_LINK=https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}
      FORGE_JAR=forge-${FORGE_VERSION}*.jar
    else
      JSON_DATA=$(curl -sSL https://files.minecraftforge.net/maven/net/minecraftforge/forge/promotions_slim.json)

      if [[ "${MC_VERSION}" == "latest" ]] || [[ "${MC_VERSION}" == "" ]]; then
        echo -e "getting latest version of forge."
        MC_VERSION=$(echo -e ${JSON_DATA} | jq -r '.promos | del(."latest-1.7.10") | del(."1.7.10-latest-1.7.10") | to_entries[] | .key | select(contains("latest")) | split("-")[0]' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | tail -1)
        BUILD_TYPE=latest
      fi

      if [[ "${BUILD_TYPE}" != "recommended" ]] && [[ "${BUILD_TYPE}" != "latest" ]]; then
        BUILD_TYPE=recommended
      fi

      echo -e "minecraft version: ${MC_VERSION}"
      echo -e "build type: ${BUILD_TYPE}"

      ## some variables for getting versions and things
      FILE_SITE=https://maven.minecraftforge.net/net/minecraftforge/forge/
      VERSION_KEY=$(echo -e ${JSON_DATA} | jq -r --arg MC_VERSION "${MC_VERSION}" --arg BUILD_TYPE "${BUILD_TYPE}" '.promos | del(."latest-1.7.10") | del(."1.7.10-latest-1.7.10") | to_entries[] | .key | select(contains($MC_VERSION)) | select(contains($BUILD_TYPE))')

      ## locating the forge version
      if [[ "${VERSION_KEY}" == "" ]] && [[ "${BUILD_TYPE}" == "recommended" ]]; then
        echo -e "dropping back to latest from recommended due to there not being a recommended version of forge for the mc version requested."
        VERSION_KEY=$(echo -e ${JSON_DATA} | jq -r --arg MC_VERSION "${MC_VERSION}" '.promos | del(."latest-1.7.10") | del(."1.7.10-latest-1.7.10") | to_entries[] | .key | select(contains($MC_VERSION)) | select(contains("latest"))')
      fi

      ## Error if the mc version set wasn't valid.
      if [ "${VERSION_KEY}" == "" ] || [ "${VERSION_KEY}" == "null" ]; then
        echo -e "The install failed because there is no valid version of forge for the version of minecraft selected."
        exit 1
      fi

      FORGE_VERSION=$(echo -e ${JSON_DATA} | jq -r --arg VERSION_KEY "$VERSION_KEY" '.promos | .[$VERSION_KEY]')

      if [[ "${MC_VERSION}" == "1.7.10" ]] || [[ "${MC_VERSION}" == "1.8.9" ]]; then
        DOWNLOAD_LINK=${FILE_SITE}${MC_VERSION}-${FORGE_VERSION}-${MC_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-${MC_VERSION}
        FORGE_JAR=forge-${MC_VERSION}-${FORGE_VERSION}-${MC_VERSION}.jar
        if [[ "${MC_VERSION}" == "1.7.10" ]]; then
          FORGE_JAR=forge-${MC_VERSION}-${FORGE_VERSION}-${MC_VERSION}-universal.jar
        fi
      else
        DOWNLOAD_LINK=${FILE_SITE}${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}
        FORGE_JAR=forge-${MC_VERSION}-${FORGE_VERSION}.jar
      fi
    fi

    #Adding .jar when not eding by SERVER_JARFILE
    if [[ ! $SERVER_JARFILE = *\.jar ]]; then
      SERVER_JARFILE="$SERVER_JARFILE.jar"
    fi

    #Downloading jars
    echo -e "Downloading forge version ${FORGE_VERSION}"
    echo -e "Download link is ${DOWNLOAD_LINK}"

    if [[ ! -z "${DOWNLOAD_LINK}" ]]; then
      if curl --output /dev/null --silent --head --fail ${DOWNLOAD_LINK}-installer.jar; then
        echo -e "installer jar download link is valid."
      else
        echo -e "link is invalid. Exiting now"
        exit 2
      fi
    else
      echo -e "no download link provided. Exiting now"
      exit 3
    fi

    curl -s -o installer.jar -sS ${DOWNLOAD_LINK}-installer.jar

    #Checking if downloaded jars exist
    if [[ ! -f ./installer.jar ]]; then
      echo "!!! Error downloading forge version ${FORGE_VERSION} !!!"
      exit
    fi

    function  unix_args {
      echo -e "Detected Forge 1.17 or newer version. Setting up forge unix args."
      ln -sf libraries/net/minecraftforge/forge/*/unix_args.txt unix_args.txt
    }

    # Delete args to support downgrading/upgrading
    rm -rf libraries/net/minecraftforge/forge
    rm unix_args.txt

    #Installing server
    echo -e "Installing forge server.\n"
    java -jar installer.jar --installServer || { echo -e "\nInstall failed using Forge version ${FORGE_VERSION} and Minecraft version ${MINECRAFT_VERSION}.\nShould you be using unlimited memory value of 0, make sure to increase the default install resource limits in the Wings config or specify exact allocated memory in the server Build Configuration instead of 0! \nOtherwise, the Forge installer will not have enough memory."; exit 4; }

    # Check if we need a symlink for 1.17+ Forge JPMS args
    if [[ $MC_VERSION =~ ^1\.(17|18|19|20|21|22|23) || $FORGE_VERSION =~ ^1\.(17|18|19|20|21|22|23) ]]; then
      unix_args

    # Check if someone has set MC to latest but overwrote it with older Forge version, otherwise we would have false positives
    elif [[ $MC_VERSION == "latest" && $FORGE_VERSION =~ ^1\.(17|18|19|20|21|22|23) ]]; then
      unix_args
    else
      # For versions below 1.17 that ship with jar
      mv $FORGE_JAR $SERVER_JARFILE
    fi

    echo -e "Deleting installer.jar file.\n"
    rm -rf installer.jar
    echo -e "Installation process is completed"
    ```
    Start: java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true $( [[  ! -f unix_args.txt ]] && printf %s "-jar {{SERVER_JARFILE}}" || printf %s "@unix_args.txt" )
    Config:
        ```json
          {
              "server.properties": {
                  "parser": "properties",
                  "find": {
                      "server-ip": "0.0.0.0",
                      "server-port": "{{server.build.default.port}}",
                      "query.port": "{{server.build.default.port}}"
                  }
              }
          }
        ```
    StartConfig:
        ```json
          {
              "done": ")! For help, type "
          }
        ```

Bungeecord: ghcr.io/pterodactyl/installers:alpine
    ```shell
        #!/bin/ash
        # Bungeecord Installation Script
        #
        # Server Files: /mnt/server

        cd /mnt/server

        if [ -z "${BUNGEE_VERSION}" ] || [ "${BUNGEE_VERSION}" == "latest" ]; then
            BUNGEE_VERSION="lastStableBuild"
        fi

        curl -o ${SERVER_JARFILE} https://ci.md-5.net/job/BungeeCord/${BUNGEE_VERSION}/artifact/bootstrap/target/BungeeCord.jar
    ```
    Start: java -Xms128M -XX:MaxRAMPercentage=95.0 -jar {{SERVER_JARFILE}}
    Config:
        ```json
            {
                "config.yml": {
                    "parser": "yaml",
                    "find": {
                        "listeners[0].query_port": "{{server.build.default.port}}",
                        "listeners[0].host": "0.0.0.0:{{server.build.default.port}}",
                        "servers.*.address": {
                            "regex:^(127\\.0\\.0\\.1|localhost)(:\\d{1,5})?$": "{{config.docker.interface}}$2"
                        }
                    }
                }
            }
        ```
    StartConfig:
        ```json
          {
              "done": "Listening on "
          }
        ```

Vanilla: ghcr.io/pterodactyl/installers:alpine
    ```shell
    #!/bin/ash
    # Vanilla MC Installation Script
    #
    # Server Files: /mnt/server
    mkdir -p /mnt/server
    cd /mnt/server

    LATEST_VERSION=`curl https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.release'`
    LATEST_SNAPSHOT_VERSION=`curl https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.snapshot'`

    echo -e "latest version is $LATEST_VERSION"
    echo -e "latest snapshot is $LATEST_SNAPSHOT_VERSION"

    if [ -z "$VANILLA_VERSION" ] || [ "$VANILLA_VERSION" == "latest" ]; then
    MANIFEST_URL=$(curl -sSL https://launchermeta.mojang.com/mc/game/version_manifest.json | jq --arg VERSION $LATEST_VERSION -r '.versions | .[] | select(.id== $VERSION )|.url')
    elif [ "$VANILLA_VERSION" == "snapshot" ]; then
    MANIFEST_URL=$(curl -sSL https://launchermeta.mojang.com/mc/game/version_manifest.json | jq --arg VERSION $LATEST_SNAPSHOT_VERSION -r '.versions | .[] | select(.id== $VERSION )|.url')
    else
    MANIFEST_URL=$(curl -sSL https://launchermeta.mojang.com/mc/game/version_manifest.json | jq --arg VERSION $VANILLA_VERSION -r '.versions | .[] | select(.id== $VERSION )|.url')
    fi

    DOWNLOAD_URL=$(curl ${MANIFEST_URL} | jq .downloads.server | jq -r '. | .url')

    echo -e "running: curl -o ${SERVER_JARFILE} $DOWNLOAD_URL"
    curl -o ${SERVER_JARFILE} $DOWNLOAD_URL

    echo -e "Install Complete"
    ```
    Start: java -Xms128M -XX:MaxRAMPercentage=95.0 -jar {{SERVER_JARFILE}}
    Config:
        ```json
            {
                "server.properties": {
                    "parser": "properties",
                    "find": {
                        "server-ip": "0.0.0.0",
                        "server-port": "{{server.build.default.port}}",
                        "query.port": "{{server.build.default.port}}"
                    }
                }
            }
        ```
    StartConfig:
        ```json
            {
                "done": ")! For help, type "
            }
        ```

Bedrock: debian:bullseye-slim
    ```shell
    #!/bin/bash
    apt update
    apt install -y zip unzip wget curl

    if [ ! -d /mnt/server/ ]; then
        mkdir /mnt/server/
    fi

    cd /mnt/server

    # Minecraft CDN Akamai blocks script user-agents
    RANDVERSION=$(echo $((1 + $RANDOM % 4000)))

    if [ -z "${BEDROCK_VERSION}" ] || [ "${BEDROCK_VERSION}" == "latest" ]; then
        echo -e "\n Downloading latest Bedrock server"
        curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" -H "Accept-Language: en" -H "Accept-Encoding: gzip, deflate" -o versions.html.gz https://www.minecraft.net/en-us/download/server/bedrock
        DOWNLOAD_URL=$(zgrep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' versions.html.gz)
    else 
        echo -e "\n Downloading ${BEDROCK_VERSION} Bedrock server"
        DOWNLOAD_URL=https://minecraft.azureedge.net/bin-linux/bedrock-server-$BEDROCK_VERSION.zip
    fi

    DOWNLOAD_FILE=$(echo ${DOWNLOAD_URL} | cut -d"/" -f5) # Retrieve archive name

    echo -e "backing up config files"
    rm *.bak versions.html.gz
    cp server.properties server.properties.bak
    cp permissions.json permissions.json.bak
    cp allowlist.json allowlist.json.bak


    echo -e "Downloading files from: $DOWNLOAD_URL"

    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" -H "Accept-Language: en" -o $DOWNLOAD_FILE $DOWNLOAD_URL

    echo -e "Unpacking server files"
    unzip -o $DOWNLOAD_FILE

    echo -e "Cleaning up after installing"
    rm $DOWNLOAD_FILE

    echo -e "restoring backup config files - on first install there will be file not found errors which you can ignore."
    cp -rf server.properties.bak server.properties
    cp -rf permissions.json.bak permissions.json
    cp -rf allowlist.json.bak allowlist.json

    chmod +x bedrock_server

    echo -e "Install Completed"
    ```
    Start: ./bedrock_server
    Config:
        ```json
            {
                "server.properties": {
                    "parser": "properties",
                    "find": {
                        "server-port": "{{server.build.default.port}}",
                        "server-name": "{{server.build.env.SERVERNAME}}",
                        "gamemode": "{{server.build.env.GAMEMODE}}",
                        "difficulty": "{{server.build.env.DIFFICULTY}}",
                        "allow-cheats": "{{server.build.env.CHEATS}}"
                    }
                }
            }
        ```
    StartConfig:
        ```json
            {
                "done": "Server started"
            }
        ```