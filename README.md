<p align="center">
  <h3 align="center"><b>Perceptio</b></h3>
  <p align="center">A multilingual, lexicon-based sentiment analysis tool for textual data.</p>
  <p align="center">
    <a href="https://github.com/lesis-lat/perceptio/blob/main/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
     <a href="https://github.com/lesis-lat/perceptio/releases">
      <img src="https://img.shields.io/badge/version-0.0.1-blue.svg">
    </a>
  </p>
</p>

---

### Summary

Perceptio (from the Latin *perceptio*, meaning "to gather, receive") is a command-line tool for measuring the emotional sentiment of a text. It operates using a lexicon-based approach, where words are scored based on their associated emotions.

Built to be extensible and easy to use, Perceptio provides the following features:
* Text analysis in multiple languages (defaults include English, Portuguese, and Spanish).
* Sentiment score calculation by identifying words in a text and summing their emotional values (e.g., positive vs. negative).
* English lexicon translation into other languages using a free translation API, making it easy to add support for new languages.
* Input acceptance directly as a string or from a file, and outputs results to the console or a file in either plain text or JSON format.

Perceptio aims to provide a simple yet effective way to perform sentiment analysis from the command line.

---

### Prerequisites

-   Perl 5.42+
-   `cpanm` (to install dependencies)

---

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/perceptio.git && cd perceptio

# Install dependencies
cpanm --installdeps .
```

---

### Usage

Perceptio is run via the `perceptio.pl` script. You can see all available commands by using the `--help` flag.

```bash
$ perl perceptio.pl --help
```
```
Perceptio v0.0.1
A multilingual sentiment analysis tool.
========================================
    Command                   Description
    -------                   -----------
    --analyze                 Analyze sentiment of the given input (string or file).
    --lang <en|pt|es>         Language code of the input (default: en).
    --input <text_or_path>    Input text string or path to a file containing text.
    --output <file>           Optional output file path (default: STDOUT).
    --format <plain|json>     Output format for sentiment result (default: plain).
    --generate-lexicons       Generate pt and es lexicons from en.json using an API.
    --overwrite               Overwrite existing lexicon files during generation.
    --list-languages          List currently available lexicon language files.
    -h, --help                Display this help menu.
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

To get structured output suitable for scripting, use the `--format json` option.

```bash
$ perl perceptio.pl --analyze --input "This is a great tool" --format json

{
  "words": [
    {
      "emotions": {
        "disgust": "0",
        "surprise": "0",
        "anticipation": "1",
        "fear": "0",
        "trust": "1",
        "negative": "0",
        "anger": "0",
        "joy": "1",
        "sadness": "0",
        "positive": "1"
      },
      "word": "happy"
    },
    {
      "emotions": {
        "anticipation": "1",
        "fear": "0",
        "surprise": "0",
        "disgust": "0",
        "positive": "0",
        "sadness": "0",
        "joy": "0",
        "anger": "0",
        "negative": "0",
        "trust": "0"
      },
      "word": "result"
    }
  ],
  "score": 1
}
```

Run the lexicon generation script to translate the base `en.json` file.

```bash
$ perl perceptio.pl --generate-lexicons

Translating to pt...
Wrote pt lexicon to resources/lexicons/pt.json
Translating to es...
Wrote es lexicon to resources/lexicons/es.json
Lexicon generation complete.
```

---

### Contribution

Your contributions and suggestions are heartily ♥ welcome. Please, report bugs via the project's issues page and see the security policy for vulnerability disclosures. (✿ ◕‿◕)

---

### License

This work is licensed under the [MIT License](/LICENSE.md).
