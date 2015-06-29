# TEMA Docker
This project contains configuration for setting up a docker instance of the Text and Math (TEMA) search system.
The basic setup is for setting up search for an [MMT](https://github.com/KWARC/MMT) archive 
but it should be straightforward to apply to other compatible by changing the configuration files.

To directly install and run this version see [Installation](#installation).
To learn how to configure TEMA search for your own archive, check the detailed documentation in [Setup Details](#setup-details) below.
Additionally, check the file `Dockerfile` as well as the `start-tema` start-up script for the actual shell commands associated with the documentation.


## Installation
After installing docker (see (https://docs.docker.com/installation/)) you can get the fully setup up version from docker hub by running  
```docker pull kwarc/mathhub```

Then you can start the web server (will start on localhost:9999) with: 
```docker run -d -p 9999:8080 kwarc/mathhub start-mh ```

For internal configuration/access (i.e. bash) you can run: 
```docker run -t -i kwarc/mathhub /bin/bash```

Don't forget to run `docker commit` afterwards to save the state.
For more information of how to configure it see the documentation below.

## Setup Details 
Starting from a bare-bones Linux installation (this instance is using Debian 8.1 -- jessie) 

1. Installing dependencies
  1. Installing plain MWS &  Miscellaneous deps, mainly `g++`, `cmake` and a bunch of libs. 
 Basically follows documentation from the [MWS readme](https://github.com/KWARC/mws).
  2. Installing dependencies for the TEMA frontend, basically elasticsearch (for searching/indexing the text), 
 php for serving and curl for setting up a couple of proxies (i.e. to the query processor (e.g. latexml) and mwsd) to avoid issues with e.g. blocked ports.
  3. Installing `npm` for yet another proxy (to elasticsearch I think) that uses `nodejs` instead of `php`.

2. Cloning and installing MWS and friends: [mws](https://github.com/KWARC/mws), [mws-frontend](https://github.com/KWARC/mws-frontend), 
and [tema-proxy](https://github.com/KWARC/tema-proxy)

3. Clone the relevant MMT archive (for which you want to set up the search engine).
The current scripts assumes the MathML-enriched HTML is in `export/planetary/narration/`
and the TEMA config in `lib/tema-config.json`. 
Additionally you can (need to) provide a query processor to convert math text queries from the input syntax 
to MathML and then provide a Javascript module in MWS frontend that posts to your converter and enable it. 
The default one is based on [LateXML](https://github.com/brucemiller/LaTeXML) and handles TeX-style input.
The parametrization of query processors should probably be improved in the MWS frontend project. 
_This is the part you need to change to make a different instance._

4. Setting up generated content
  1. generate MWS harvests (via `mws/bin/docs2harvest`)
  2. generate MWS index (via `mws/bin/mws-index`)
  3. generate elasticsearch annotated documents (via `mws/bin/harvests2json`)
 
5. Starting everything up (see separate startup script `start-tema`)
  1. Start the elasticsearch service
  2. Load the generated index (annotated documents) into elasticsearch (using the scripts `run-setup` and then 
   `run-bulk` from `mws/scripts/elasticsearch/`)
  3. Start the MWS daemon to serve the index
  4. Start tema-proxy with `nodejs` 
  5. Serve mws-frontend (php will take care of the other two proxies)

