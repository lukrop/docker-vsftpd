# VSFTPD Docker Image

[![Docker Repository on Quay.io](https://quay.io/repository/panubo/vsftpd/status "Docker Repository on Quay.io")](https://quay.io/repository/panubo/vsftpd)
[![](https://badge.imagelayers.io/panubo/vsftpd:latest.svg)](https://imagelayers.io/?images=panubo/vsftpd:latest)

This is a micro-service image for VSFTPD.

There are a few limitations but it will work if you are using host networking
`--net host` or have a direct/routed network between the Docker container and
the client.

## Virtual User

The FTP user has been set to uid 48 and gid 48. This can be changed using the environment variables
`FTP_UID` and `FTP_GID`.

## Options

The following environment variables are accepted.

- `FTP_UID`: Sets the UID of the FTP user. Default 48.

- `FTP_GID`: Sets the GID of the FTP user. Default 48.

- `FTP_USER`: Sets the default FTP user 

- `FTP_PASSWORD`: Plain text password, or

- `FTP_PASSWORD_HASH`: Sets the password for the user specified above. This
requires a hashed password such as the ones created with `mkpasswd -m sha-512`
which is in the _whois_ debian package.

- `FTP_USER_*`: Adds mutliple users. Value must be in the form of `username:hash` or `username:hash:home`. Should not be used in conjunction with `FTP_USER` and `FTP_PASSWORD(_HASH)`. The second form `user:hash:home` allows to set a custom local_root for this user.

- `FTP_USERS_ROOT`: sets `local_root=/srv/$USER` so each user is chrooted to their own directory instead of a shared one.

## Usage Example

```
docker run --rm -it -p 21:21 -p 4559:4559 -p 4560:4560 -p 4561:4561 -p 4562:4562 -p 4563:4563 -p 4564:4564 -e FTP_USER=panubo -e FTP_PASSWORD=panubo panubo/vsftpd
```

## SSL Usage

SSL can be configured (non-SSL by default). Firstly the SSL certificate and key
need to be added to the image, either using volumes or baking it into an image.
Then specify the `vsftpd_ssl.conf` config file as the config vsftpd should use.

This example assumes the ssl cert and key are in the same file and are mounted
into the container read-only.

```
docker run --rm -it -e FTP_USER=panubo -e FTP_PASSWORD_HASH='$6$XWpu...DwK1' -v `pwd`/server.pem:/etc/ssl/certs/vsftpd.crt:ro -v `pwd`/server.pem:/etc/ssl/private/vsftpd.key:ro panubo/vsftpd vsftpd /etc/vsftpd_ssl.conf
```
