# This file is a part of Julia. License is MIT: http://julialang.org/license

export latex

function wrapblock(f, io, env)
    println(io, "\\begin{", env, "}")
    f()
    println(io, "\\end{", env, "}")
end

function wrapinline(f, io, cmd)
    print(io, "\\", cmd, "{")
    f()
    print(io, "}")
end

# Block elements

latex(io::IO, md::MD) = latex(io, md.content)

# Inline elements

function latexinline(io::IO, md::String)
    latexesc(io, md)
end

const _latexescape_chars = Dict{Char, String}(
   '~'=>"{\\sim}", '^'=>"\\^{}", '\\'=>"{\\textbackslash}")
for ch in "&%\$#_{}"
    _latexescape_chars[ch] = "\\$ch"
end

function latexesc(io, s::String)
    for ch in s
        print(io, get(_latexescape_chars, ch, ch))
    end
end

latex(md) = sprint(latex, md)
latexinline(md) = sprint(latexinline, md)

latexesc(s) = sprint(latexesc, s)

# TODO should this be text/plain ? What is a good fallback here?
latex(io::IO, x) = writemime(io, MIME"text/latex"(), x)
latexinline(io::IO, x) = writemime(io, MIME"text/latex"(), x)
writemime(io::IO, ::MIME"text/latex", md::MD) = latex(io, md)
#writemime(io::IO, ::MIME"text/latex", md::MD) = writemime(io, "text/plain", md)
