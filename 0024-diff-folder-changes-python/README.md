# Diff folder changes

:)

## Requirements

- Python v3.9.6

## Testing

Create virtual environment, install dependencies, activate environment and create storage directory for checksum files

```
make venv
make vendor
source venv/bin/activate
mkdir ./storage
mkdir ./target # run when you want place project to this directory
```

Dump the default checksum file from target directory

```
python3 main.py --dump --path=/path/to/target/directory
```

Diff target directory with default checksum file

```
python3 main.py --diff --path=/path/to/target/directory
```

Run watchdog for compare

```
make watch
```
