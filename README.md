# umqtt_python
Make a python umqtt package from https://github.com/micropython/micropython-lib/


## Introduction
It is a bit weird why I have to use the umqtt library in (c)python.
The reason is that I want to first test some mqtt functions on my
laptop instead of a microcontroller.

## How to use
Just run the following script.

```shell
./make.sh
```

It will download the [code](https://github.com/micropython/micropython-lib/),
patch files and build a wheel in `./build`.

You may noticed that I download the source code through `ssh`. Change it to
`https` if you'd like.
```shell
if ! [[ -d micropython-lib ]]; then
  git clone git@github.com:micropython/micropython-lib
fi
```
