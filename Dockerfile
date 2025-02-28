FROM debian:bookworm 

RUN apt update && apt upgrade -y
RUN apt install bash curl wget coreutils unzip fasttext -y


RUN groupadd -r langtool && \
    useradd -r -g langtool -m langtool


RUN mkdir -p /langtool/models/ngrams /langtool/models/fasttext /langtool/src /workspace && chown -R langtool /workspace /langtool


WORKDIR  /langtool/models/ngrams

# We could do something like wget -r --accept-regex="ngrams-[a-z]{2}-.*\.zip" https://languagetool.org/download/ngram-data/
# However, different layers with smaller sizes are needed to build this with github actions.
# See Dockerfile.alpine and Dockerfile.alpine

RUN wget --tries=10 https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip
RUN unzip "ngrams-en-20150817.zip" && rm -rf "ngrams-en-20150817.zip"
RUN wget --tries=10 https://languagetool.org/download/ngram-data/ngrams-de-20150819.zip
RUN unzip "ngrams-de-20150819.zip" && rm -rf "ngrams-de-20150819.zip"
RUN wget --tries=10 https://languagetool.org/download/ngram-data/ngrams-es-20150915.zip
RUN unzip "ngrams-es-20150915.zip" && rm -rf "ngrams-es-20150915.zip"
RUN wget --tries=10 https://languagetool.org/download/ngram-data/ngrams-fr-20150913.zip
RUN unzip "ngrams-fr-20150913.zip" && rm -rf "ngrams-fr-20150913.zip"
RUN wget --tries=10 https://languagetool.org/download/ngram-data/ngrams-nl-20181229.zip
RUN unzip "ngrams-nl-20181229.zip" && rm -rf "ngrams-nl-20181229.zip"


# Untested
RUN wget --tries=10 https://languagetool.org/download/ngram-data/untested/ngram-he-20150916.zip
RUN unzip "ngram-he-20150916.zip" && rm -rf "ngram-he-20150916.zip"
RUN wget --tries=10 https://languagetool.org/download/ngram-data/untested/ngram-it-20150915.zip
RUN unzip "ngram-it-20150915.zip" && rm -rf "ngram-it-20150915.zip"
RUN wget --tries=10 https://languagetool.org/download/ngram-data/untested/ngram-ru-20150914.zip
RUN unzip "ngram-ru-20150914.zip" && rm -rf "ngram-ru-20150914.zip"
RUN wget --tries=10 https://languagetool.org/download/ngram-data/untested/ngram-zh-20150916.zip
RUN unzip "ngram-zh-20150916.zip" && rm -rf "ngram-zh-20150916.zip"


WORKDIR /langtool/models/fasttext
RUN wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin 

WORKDIR  /langtool/src
RUN curl -L https://raw.githubusercontent.com/languagetool-org/languagetool/master/install.sh | bash

RUN mv $(dirname $(find . -type f -name "languagetool-commandline.jar")) "/langtool/dist"
RUN cd / && rm -rf /langtool/src

RUN apt remove unzip wget curl -y
RUN apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists

USER langtool

ENTRYPOINT ["java", "-jar", "/langtool/dist/languagetool-commandline.jar", "--fasttextbinary", "/usr/bin/fasttext", "--fasttextmodel", "/langtool/models/fasttext/lid.176.bin", "--languagemodel", "/langtool/models/ngrams"]

WORKDIR /workspace