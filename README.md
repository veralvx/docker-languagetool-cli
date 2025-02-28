> LanguageTool is an Open Source proofreading software for English, Spanish, French, German, Portuguese, Polish, Dutch, and more than 20 other languages. It finds many errors that a simple spell checker cannot detect.

The source code of LanguageTool is available [here](https://github.com/languagetool-org/languagetool)

This repo provides a `Dockerfile` that creates an image with `ngrams` datasets and `fasttext` downloaded into it (which also causes the image to occupy some gigabytes). I wanted a client for LanguageTool that was portable, without thinking about mounting directories for full function.

Build the image:

```
podman build -f Dockerfile -t languagetool
```

Run it:

```
podman run --rm --volume $(pwd):/workspace languagetool <file>
```

