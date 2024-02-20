\LoadClass[twoside,a4paper]{article}
\NeedsTeXFormat{LaTeX2e}

\RequirePackage{graphicx}
\RequirePackage{helvet}
\RequirePackage{fancyhdr}
%\RequirePackage{fancyvrb}
%\RequirePackage[includehead,includefoot,top=50pt,bottom=50pt,headheight=24pt,margin=1in]{geometry}
\RequirePackage[includehead,includefoot,top=50pt,bottom=50pt,headheight=24pt]{geometry}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{multirow}
\RequirePackage{verbatim}
\RequirePackage{geometry}
\RequirePackage{bm}
\RequirePackage{tabularx}
\RequirePackage{lipsum}
\RequirePackage{catchfile}
\RequirePackage[all]{nowidow}
\RequirePackage{enumerate}
\RequirePackage{enumitem}
\RequirePackage{longtable}

\RequirePackage{float}
\RequirePackage{color, colortbl}
\RequirePackage[section]{placeins}
\RequirePackage{mathtools}
\RequirePackage{amsthm}
\RequirePackage[OT1]{fontenc} 
\RequirePackage{array}
\RequirePackage[binary-units=true]{siunitx}
\RequirePackage[all]{nowidow}
\RequirePackage{lscape}

\widowpenalty10000
\clubpenalty10000

\newcolumntype{P}[1]{>{\centering\arraybackslash}p{#1}}

\geometry{
 a4paper,
 total={170mm,257mm},
 left=20mm,
 top=20mm,
}

\pagestyle{fancy}
\graphicspath{ {./figures} }
\setlength{\parskip}{\baselineskip}


\renewcommand{\headrulewidth}{.4pt}
\fancyhead{}
\fancyhead[RO,LE]{
\textbf{\@header}
\\
\textsc{\small{\@category}}
}
\fancyhead[RE,LO]{\includegraphics[scale=.15]{Logo.png}}

\renewcommand{\footruleskip}{10pt}
\renewcommand{\footrulewidth}{.4pt}

\fancyfoot{}
\fancyfoot[LO,RE]{\copyright \the\year{} IObundle Lda. All rights reserved\hspace{1cm}\url{www.iobundle.com}\hspace{1cm}{\bf Confidential}}
\fancyfoot[LE,RO]{\thepage}

\newcommand{\category}[1]{\def\@category{#1}}
\newcommand{\header}[1]{\def\@header{#1}}

\renewcommand{\familydefault}{\sfdefault}

\newcommand{\getenv}[2][]{%
  \CatchFileEdef{\temp}{"|kpsewhich --var-value #2"}{\endlinechar=-1}%
  \if\relax\detokenize{#1}\relax\temp\else\let#1\temp\fi}

\graphicspath{ {./figures/} }

