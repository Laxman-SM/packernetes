#!/bin/bash

echo TODO

date | tee /root/MASTER.md

cat >/root/.screenrc<<EOF
hardstatus alwayslastline

hardstatus string '%{= kG} MASTER [%= %{= kw}%?%-Lw%?%{r}[%{W}%n*%f %t%?{%u}%?%{r}]%{w}%?%+Lw%?%?%= %{g}] %{W}%{g}%{.w} screen %{.c} [%H]'
EOF

exit 0

