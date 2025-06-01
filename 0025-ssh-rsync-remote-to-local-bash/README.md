# SSH rsync remote to local

:)

## Requirements

- Bash v3.2.57
- Rsync v2.6.9

## Testing

Generate private and public key in local

```
ssh-keygen -f ~/.ssh/id_ed25519.name -t ed25519 -a 100
```

Create new host in `~/.ssh/config` like:

```
Host anyhost
    Hostname        123.123.123.123
    User            username
    Port            22
    IdentityFile    ~/.ssh/id_ed25519.name
```

Copy the public key to remote

```
# manually copy & paste to remote `~/.ssh/authorized_keys` file
cat ~/.ssh/id_ed25519.name.pub | pbcopy

# or `ssh`
cat ~/.ssh/id_ed25519.pub | ssh username@anyhost 'umask 0077 && mkdir -p .ssh; cat >> .ssh/authorized_keys'

# or `ssh-copy-id`
ssh-copy-id -i ~/.ssh/id_ed25519.name.pub username@anyhost
```

Run the code (*need update the variable in script file*)

```
bash /path/to/project/backup.sh
```

Add to crontab and save last `echo` message to text log

```
crontab -e
/bin/bash /path/to/project/backup.sh | tail -n 1 >> /path/to/project/backup.txt
```
