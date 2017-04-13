#!/bin/bash

echo TODO

date | tee /root/WORKER.md

cat >/root/.screenrc<<EOF
hardstatus alwayslastline

hardstatus string '%{= kG} WORKER [%= %{= kw}%?%-Lw%?%{r}[%{W}%n*%f %t%?{%u}%?%{r}]%{w}%?%+Lw%?%?%= %{g}] %{W}%{g}%{.w} screen %{.c} [%H]'
EOF

exit 0
