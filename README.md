## quick_axfr is a tool for bulk domain zone transfers

Usage is simple:

./quick_axfr.rb domains.txt

The tool will parse through each domain in domains.txt, find the name servers for that domain and then attempt a zone transfer against each. Simples.
