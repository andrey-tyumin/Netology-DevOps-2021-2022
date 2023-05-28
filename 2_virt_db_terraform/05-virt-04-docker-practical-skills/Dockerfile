FROM archlinux:latest

RUN pacman -Syy && \
    pacman -S --noconfirm ponysay
 
ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology"]
