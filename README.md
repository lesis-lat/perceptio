<p align="center">
  <h3 align="center"><b>Perceptio</b></h3>
  <p align="center">A multilingual, lexicon-based sentiment analysis framework for textual data.</p>
  <p align="center">
    <a href="/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
     <a href="https://github.com/instriq/security-gate/releases">
      <img src="https://img.shields.io/badge/version-0.1.0-blue.svg">
    </a>
    <img src="https://github.com/instriq/perceptio/actions/workflows/linter.yml/badge.svg">
    <img src="https://github.com/instriq/perceptio/actions/workflows/zarn.yml/badge.svg">
    <img src="https://github.com/instriq/perceptio/actions/workflows/security-gate.yml/badge.svg">
    <img src="https://img.shields.io/badge/coverage-93.3%25-brightgreen.svg">
  </p>
</p>

---

### Summary

Perceptio (from the Latin *perceptio*, meaning "to gather, receive") is a command-line framework for measuring the emotional sentiment of a text. It operates using a lexicon-based approach, where words are scored based on their associated emotions.

Built to be extensible and easy to use, Perceptio provides the following features:
* Text analysis in multiple languages (defaults include English) with automatic language detection.
* Granular sentiment analysis on a whole document or on a sentence-by-sentence basis.
* Translation of English lexicons and abbreviation lists into other languages using the Google Cloud Translation API, making it easy to add support for new languages.
* Input acceptance directly as a string or from a file, and outputs results to the console or a file in either plain text or JSON format.

Perceptio aims to provide a simple yet effective way to perform sentiment analysis from the command line.

---

### Prerequisites

-  Perl v5.42+
-  `cpanm` (to install dependencies)
-  A Google Cloud API Key for the resource translation feature.

---

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/perceptio.git && cd perceptio

# Install dependencies
cpanm --installdeps .

# Set API Key
export GOOGLE_API_KEY="your_api_key_here"
```

---

### Usage

Perceptio is run via the `perceptio.pl` script. You can see all available commands by using the `--help` flag.

```bash
$ perl perceptio.pl --help
```
```
Perceptio v0.0.1
A multilingual sentiment analysis framework.
============================================
    Command                       Description
    -------                       -----------
    --analyze                     Analyze sentiment of the given input (string or file).
    --auto                        Automatically identify the language of the given input.
    --lang <en|pt|es>             Language code of the input (default: en).
    --input <text_or_path>        Input text string or path to a file containing text.
    --output <file>               Optional output file path (default: STDOUT).
    --format <plain|json>         Output format for sentiment result (default: plain).
    --by-sentence                 Analyze sentiment for each sentence individually.
    --generate-resources [type]   Generate translated resource files. Type can be 'lexicons',
                                  'abbreviations', or 'all' (default).
    --overwrite                   Overwrite existing resource files during generation.
    --list-languages              List currently available lexicon language files.
    -h, --help                    Display this help menu.
```

You can also build and run Perceptio using the included `Dockerfile`.

```bash
# Build the Docker image
docker build -t perceptio .

# Run commands via the container:

# Get help menu
docker run --rm perceptio --help

# Analyze a string
docker run --rm perceptio --analyze --input "I am very happy with the result!"

# To analyze a local file, you must mount it into the container
docker run --rm -v "$(pwd)/my_text.txt:/app/my_text.txt" \
perceptio --analyze --input my_text.txt --lang en
```

---

### Example

Analyze a sentence and print the results in the default plain text format. The score is calculated as `positive - negative`.

```bash
$ perl perceptio.pl --analyze --input "I love happy days, but I hate sad moments."

Sentiment Score: 1
Matched Words:
  - Word: 'love', Sentiment: positive, Score: 1
  - Word: 'happy', Sentiment: positive, Score: 1
  - Word: 'hate', Sentiment: negative, Score: -1
```

Use the --by-sentence flag to analyze each sentence individually.

```bash
$ perl perceptio.pl --analyze --input "I love happy days. I hate sad moments." --by-sentence

Sentence 1: "I love happy days."
  Sentiment Score: 2
  Matched Words:
    - Word: 'love', Sentiment: positive, Score: 1
    - Word: 'happy', Sentiment: positive, Score: 1
---
Sentence 2: "I hate sad moments."
  Sentiment Score: -1
  Matched Words:
    - Word: 'hate', Sentiment: negative, Score: -1
```

To get structured output suitable for scripting, use the `--format json` option.

```bash
$ perceptio % perl perceptio.pl --analyze --input "I love happy days, but I hate sad moments." --format json

{
   "score" : 1,
   "words" : [
      {
         "emotions" : {
            "anger" : "0",
            "anticipation" : "0",
            "disgust" : "0",
            "fear" : "0",
            "joy" : "1",
            "negative" : "0",
            "positive" : "1",
            "sadness" : "0",
            "surprise" : "0",
            "trust" : "0"
         },
         "word" : "love"
      },
      {
         "emotions" : {
            "anger" : "0",
            "anticipation" : "1",
            "disgust" : "0",
            "fear" : "0",
            "joy" : "1",
            "negative" : "0",
            "positive" : "1",
            "sadness" : "0",
            "surprise" : "0",
            "trust" : "1"
         },
         "word" : "happy"
      },
      {
         "emotions" : {
            "anger" : "1",
            "anticipation" : "0",
            "disgust" : "1",
            "fear" : "1",
            "joy" : "0",
            "negative" : "1",
            "positive" : "0",
            "sadness" : "1",
            "surprise" : "0",
            "trust" : "0"
         },
         "word" : "hate"
      }
   ]
}
```

Run the resource generation script to translate the base en.json files for lexicons and abbreviations. Remember to set your GOOGLE_API_KEY.

```bash
$ perl perceptio.pl --generate-resources

Translating lexicons to pt...
Wrote pt lexicons to resources/lexicons/pt.json
Translating lexicons to es...
Wrote es lexicons to resources/lexicons/es.json
Translating abbreviations to pt...
Wrote pt abbreviations to resources/abbreviations/pt.json
Translating abbreviations to es...
Wrote es abbreviations to resources/abbreviations/es.json
Resource generation complete.
```

---

### Contribution

Your contributions and suggestions are heartily ♥ welcome. Please, report bugs via the project's issues page and see the security policy for vulnerability disclosures. (✿ ◕‿◕)

---

### License

This work is licensed under the [MIT License](/LICENSE.md).
