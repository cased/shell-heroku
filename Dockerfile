FROM ghcr.io/cased/shell:unstable
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD []
RUN curl https://cli-assets.heroku.com/install.sh | sh
ADD entrypoint.sh prompts.pre.json /
COPY --from=ghcr.io/cased/ssh-oauth-handlers:latest /bin/app /bin/heroku-ssh
