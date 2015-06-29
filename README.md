# TEMA_docker
Configuration for setting up a docker instance of TEMA search.
For more details see the documentation below of how to set up an instance of the Text and Math (TEMA) search system. 
Additionally check the file `Dockerfile` as well as the `start-tema` start-up script for the actual shell commands associated with this documentation.


## TEMA Search Setup Steps
0. Starting from a bare-bones Linux installation (this instance is using Debian 8.1 -- jessie) 
1. Installing dependencies
 1.1. Installing plain MWS &  Miscellaneous deps, mainly `g++`, `cmake` and a bunch of libs. 
 Basically follows documentation from the [MWS readme](https://github.com/KWARC/mws).
 1.2. Installing dependencies for the TEMA frontend, basically elasticsearch (for searching/indexing the text), 
 php for serving and curl for setting up a couple of proxies (i.e. to the query processor (e.g. latexml) and mwsd) to avoid issues with e.g. blocked ports.
 1.3. Installing `npm` for yet another proxy (to elasticsearch I think) that uses `nodejs` instead of `php`.

2. Cloning and installing MWS and friends: [mws](https://github.com/KWARC/mws), [mws-frontend](https://github.com/KWARC/mws-frontend), 
and [tema-proxy](https://github.com/KWARC/tema-proxy)

3. Clone the relevant MMT archive (for which you want to set up the search engine).
The current scripts assumes the MathML-enriched HTML is in `export/planetary/narration/`
and the TEMA config in `lib/tema-config.json`. 
_This is the part you need to change to make a different instance._

4. Setting up generated content
  4.1. generate MWS harvests (via `mws/bin/docs2harvest`)
  4.2. generate MWS index (via `mws/bin/mws-index`)
  4.3. generate elasticsearch annotated documents (via `mws/bin/harvests2json`)
 
5. Starting everything up (see separate startup script `start-tema`)
   5.1. Start the elasticsearch service
   5.2. Load the generated index (annotated documents) into elasticsearch (using the scripts `run-setup` and then 
   `run-bulk` from `mws/scripts/elasticsearch/`)
   5.3. Start the MWS daemon to serve the index
   5.4. Start tema-proxy with `nodejs` 
   5.5. Serve mws-frontend (php will take care of the other two proxies)

