#!/bin/sh

LAYOUT=layout_fns
ASCIIDOC_HTML="asciidoc -v --backend=html5 --conf-file=${LAYOUT}.conf --attribute=linkcss --attribute=iconsdir=./images/icons --attribute=icons"

$ASCIIDOC_HTML --attribute=body-id='index' -o index.html index.txt
$ASCIIDOC_HTML --attribute=body-id='about' -o about.html about.txt
$ASCIIDOC_HTML --attribute=body-id='features' -o features.html features.txt
$ASCIIDOC_HTML --attribute=body-id='faq' -o faq.html faq.txt
$ASCIIDOC_HTML --attribute=body-id='usage' -o usage.html fns-usage.txt
$ASCIIDOC_HTML --attribute=body-id='configuration' -o configuration.html fns-configuration.txt
$ASCIIDOC_HTML --attribute=body-id='advanced' -o advanced.html fns-advanced.txt
$ASCIIDOC_HTML --attribute=body-id='install' --attribute=iconsdir=./images/icons --attribute=icons -o install.html install.txt
$ASCIIDOC_HTML --attribute=body-id='fnsbasesetup' -o fnsbasesetup.html FNS-BaseSetup.txt
$ASCIIDOC_HTML --attribute=body-id='fnsmenuconfigurator' -o fnsmenuconfigurator.html FNS-MenuConfigurator.txt
$ASCIIDOC_HTML --attribute=body-id='fnscompconfigurator' -o fnscompconfigurator.html FNS-CompConfigurator.txt
$ASCIIDOC_HTML --attribute=body-id='fnscpuperformance' -o fnscpuperformance.html FNS-CpuPerformance.txt
$ASCIIDOC_HTML --attribute=body-id='fnswindowsbehaviour' -o fnswindowsbehaviour.html FNS-WindowsBehaviour.txt
$ASCIIDOC_HTML --attribute=body-id='fnspersonalmenu' -o fnspersonalmenu.html FNS-MenuBuilder.txt
$ASCIIDOC_HTML --attribute=body-id='tools' -o tools.html tools.txt
$ASCIIDOC_HTML --attribute=body-id='develop' -o development.html get-involved.txt
$ASCIIDOC_HTML --attribute=body-id='contact' -o contact.html contact.txt
$ASCIIDOC_HTML --attribute=body-id='downloads' -o downloads.html downloads.txt
$ASCIIDOC_HTML --attribute=body-id='news' -o news.html news.txt
$ASCIIDOC_HTML --attribute=body-id='blog' -o blog.html blog.txt
$ASCIIDOC_HTML --attribute=body-id='screenshots' -o screenshots.html screenshots.txt
