\LoadClass[twoside,twocolumn,a4paper]{article}
\NeedsTeXFormat{LaTeX2e}

\RequirePackage{graphicx}
\RequirePackage{helvet}
\RequirePackage{fancyhdr}
\RequirePackage[includehead,includefoot,top=50pt,bottom=50pt,headheight=24pt]{geometry}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{geometry}
\RequirePackage{enumitem}
\RequirePackage{titlesec}
\RequirePackage{catchfile}
\RequirePackage{color,soul}
\RequirePackage{float}
\RequirePackage{makecell}
\RequirePackage{lipsum}
\RequirePackage[table,xcdraw]{xcolor}
\RequirePackage{calc}
\RequirePackage{eso-pic}
\RequirePackage[binary-units=true]{siunitx}
\RequirePackage{subcaption}
\RequirePackage{caption,tabularx,booktabs}
\RequirePackage{longtable}
\RequirePackage[all]{nowidow}
\widowpenalty10000

\RequirePackage{lscape}


\setitemize{labelindent=2mm,labelsep=1mm,leftmargin=*}

\setlength{\parindent}{1.0ex}
\setlength{\parskip}{0.7ex}

\titlespacing*{\section}
{0pt}{1.5ex plus 0.5ex minus .2ex}{1.3ex plus .2ex}

\geometry{
 a4paper,
 total={170mm,257mm},
 left=20mm,
 top=20mm,
}

\graphicspath{ {./figures} }

\renewcommand{\headrulewidth}{.4pt}
\fancyhead{}
\fancyhead[RO,LE]{
\textbf{\@title}
\\
\textsc{\small{\@category}}
}
\fancyhead[RE,LO]{\includegraphics[scale=.4]{Logo.png}}

\newcommand{\confidential}{\def\@confidential}
\renewcommand{\footruleskip}{10pt}
\renewcommand{\footrulewidth}{.4pt}
\fancyfoot{}
%\fancyfoot[RO,LE]{
\fancyfoot[L]{\copyright \the\year{} IObundle Lda. All rights reserved}
\fancyfoot[R]{\url{www.IObundle.com}}
%\fancyfoot[RE,LO]{\@ifundefined{@confidential}{}{\textbf{Confidential}}}
%\thepage
%}

\newcommand{\category}[1]{\def\@category{#1}}
\renewcommand{\familydefault}{\sfdefault}

\renewcommand{\maketitle}{
\begin{titlepage}
\setlength{\parindent}{0pt}
\setlength{\parskip}{1ex}
\vspace*{100pt}
\Huge{\textbf{\@title}}

\huge{\@category}

\vspace*{2ex}
\includegraphics[keepaspectratio,scale=.7]{Logo.png}

\small{\today}
\vspace*{\fill}
\end{titlepage}
}

\newcommand{\getenv}[2][]{%
  \CatchFileEdef{\temp}{"|kpsewhich --var-value #2"}{\endlinechar=-1}%
  \if\relax\detokenize{#1}\relax\temp\else\let#1\temp\fi}
