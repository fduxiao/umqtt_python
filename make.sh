#!/bin/sh
if ! [[ -d build ]]; then
  mkdir -pv build
fi
# go to build
cd build

if ! [[ -d micropython-lib ]]; then
  git clone git@github.com:micropython/micropython-lib
fi

# fetch the most recent code
cd micropython-lib
git fetch origin master
git reset --hard origin/master
# then go back
cd ..

# prepare python files
if ! [[ -d umqtt_package/umqtt ]]; then
  mkdir -pv umqtt_package/umqtt
fi

touch umqtt_package/umqtt/__init__.py
cp -v ./micropython-lib/micropython/umqtt.simple/umqtt/simple.py umqtt_package/umqtt/
cp -v ./micropython-lib/micropython/umqtt.robust/umqtt/robust.py umqtt_package/umqtt/
cp -v micropython-lib/LICENSE umqtt_package/
cp -v ../README.md ./umqtt_package

# patching
sed -i'' -e "s/socket.socket()/MySocket()/" umqtt_package/umqtt/simple.py
cat >> umqtt_package/umqtt/simple.py << EOF


class MySocket(socket.socket):
    def recv(self, length):
        try:
            return super().recv(length)
        except BlockingIOError:
            return None

    def read(self, size=-1):
        result = bytearray()
        while size == -1 or size > 0:
            bs = self.recv(size)
            if bs is None:
                if len(result) == 0:
                    return None
                break
            if len(bs) == 0:
                break
            result.extend(bs)
            size -= len(bs)
        return bytes(result)


    def write(self, data, length=-1):
        if isinstance(data, str):
            data = data.encode()
        if length > 0:
            data = data[:length]
        return self.send(data)
EOF

# prepare pyproject.toml
# get version
VERSION=$(sed -nr -e 's/^.*version="(.*)".*$/\1/p' micropython-lib/micropython/umqtt.simple/manifest.py)
echo version is ${VERSION}

cat > umqtt_package/pyproject.toml << EOF
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[tool.setuptools.packages.find]
include = ["umqtt"]

[project]
name = "umqtt"
version = "${VERSION}"

readme = "README.md"
license = {file = "LICENSE"}
keywords = ["sample", "setuptools", "development"]
EOF

# build the package
pip wheel ./umqtt_package
cd ..
ls ${PWD}/build/umqtt*.whl
