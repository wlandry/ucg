# UniversalCodeGrep

UniversalCodeGrep (ucg) is another [Ack](http://beyondgrep.com/) clone.  It is an extremely fast grep-like tool specialized for searching large bodies of source code.

`ucg` is written in C++ and takes advantage of the C++11 and newer facilities of the language to reduce reliance on non-standard libraries, increase portability, and increase scanning speed.

As a consequence of `ucg`'s use of these facilities and its overall design for maximum concurrency and speed, `ucg` is extremely fast.  Under Fedora 23, scanning the Boost 1.58.0 source tree with `ucg` 0.2.0, [`ag`](http://geoff.greer.fm/ag/) 0.30.0, and `ack` 2.14 produces the following results:

| Command | Approximate Real Time |
|---------|-----------------------|
| `time ucg 'BOOST.*HPP' ~/src/boost_1_58_0` | ~ 0.53 seconds |
| `time ag 'BOOST.*HPP' ~/src/boost_1_58_0` | ~ 11.1 seconds |
| `time ack 'BOOST.*HPP' ~/src/boost_1_58_0` | ~ 18.3 seconds |

## License

[GPL (Version 3 only)](https://github.com/gvansickle/ucg/blob/master/COPYING)

## Installation

UniversalCodeGrep installs from the distribution tarball (available [here](https://github.com/gvansickle/ucg/releases/download/0.2.0/universalcodegrep-0.2.0.tar.gz)) in the standard autotools manner:

```sh
tar -xaf universalcodegrep-0.2.0.tar.gz
cd universalcodegrep-0.2.0.tar.gz
./configure
make
make install
```

This will install the `ucg` executable in `/usr/local/bin`.  If you wish to install it elsewhere or don't have permissions on `/usr/local/bin`, specify an installation prefix on the `./configure` command line:

```sh
./configure --prefix=~/<install-root-dir>
```

### Prerequisites

- `gcc` version 4.9 or greater.

Versions of `gcc` prior to 4.9 are known to ship with an incomplete implementation of the standard `<regex>` library.  Since `ucg` depends on this C++11 feature, `configure` attempts to detect a broken `<regex>` at configure-time.

### Supported OSes and Distributions

UniversalCodeGrep should build and function anywhere there's a `gcc` 4.9 or greater available.  It has been tested on the following OSes/distros:

- Linux
  - Ubuntu 15.04 (with gcc 4.9.2, the current default compiler on this distro)
- Windows 7 + Cygwin 64-bit (with gcc 4.9.3, the current default compiler on this distro)

## Usage

Invoking `ucg` is the same as with `ack` or `ag`:

```sh
ucg [OPTION...] PATTERN [FILES OR DIRECTORIES]
```

...where `PATTERN` is an ECMAScript-compatible regular expression.

If no `FILES OR DIRECTORIES` are specified, searching starts in the current directory.

### Command Line Options

Version 0.2.0 of `ucg` supports a significant subset of the options supported by `ack`.  Future releases will have support for more options.

#### Searching

| Option | Description |
|----------------------|------------------------------------------|
| `-i, --ignore-case`  |      Ignore case distinctions in PATTERN        |
| `-Q, --literal`      |     Treat all characters in PATTERN as literal. |
| `-w, --word-regexp`  |      PATTERN must match a complete word.        |



#### File presentation

| Option | Description |
|----------------------|------------------------------------------|
| `--color, --colour`     | Render the output with ANSI color codes.    |
| `--nocolor, --nocolour` | Render the output without ANSI color codes. |

#### File inclusion/exclusion:
| Option | Description |
|----------------------|------------------------------------------|
| `--ignore-dir=name, --ignore-directory=name`     | Exclude directories with this name.        |
| `--noignore-dir=name, --noignore-directory=name` | Do not exclude directories with this name. |
| `-n, --no-recurse`                               | Do not recurse into subdirectories.        |
| `-r, -R, --recurse`                              | Recurse into subdirectories (default: on). |
| `--type=[no]TYPE`                                | Include only [exclude all] TYPE files.     |

#### File type specification:
| Option | Description |
|----------------------|------------------------------------------|
| `--type-add=TYPE:FILTER:FILTERARGS` | Files FILTERed with the given FILTERARGS are |
|                                               | treated as belonging to type TYPE.  Any existing |
                             definition of type TYPE is appended to. |
| `--type-del=TYPE`                   | Remove any existing definition of type TYPE. |
| `--type-set=TYPE:FILTER:FILTERARGS` | Files FILTERed with the given FILTERARGS are
                             treated as belonging to type TYPE.  Any existing
                             definition of type TYPE is replaced. |

#### Miscellaneous:
| Option | Description |
|----------------------|------------------------------------------|
| `-j, --jobs=NUM_JOBS` | Number of scanner jobs (std::thread<>s) to use. |
| `--noenv`             | Ignore .ucgrc files.                            |

#### Informational options:
| Option | Description |
|----------------------|------------------------------------------|
| `-?, --help`                      | give this help list                 |
| `--help-types, --list-file-types` | Print list of supported file types. |
| `--usage`                         | give a short usage message          |
| `-V, --version`                   | print program version               |


## Author

Gary R. Van Sickle
