using Base.Markdown
import Base.Markdown: MD, Paragraph, Header, Italic, Bold, plain, term, html, Table, Code
import Base: writemime

# Basics
# Equality is checked by making sure the HTML output is
# the same – the structure itself may be different.

@test md"foo" == MD(Paragraph("foo"))
@test md"foo *bar* baz" == MD(Paragraph(["foo ", Italic("bar"), " baz"]))

@test md"#title" == MD(Header{1}("title"))
@test md"## section" == MD(Header{2}("section"))
@test md"# title *foo* `bar` **baz**" ==
    MD(Header{1}(["title ", Italic("foo")," ",Code("bar")," ",Bold("baz")]))

@test md"**foo *bar* baz**" == MD(Paragraph(Bold(["foo ", Italic("bar"), " baz"])))
# @test md"**foo *bar* baz**" == MD(Paragraph(Italic(["foo ", Bold("bar"), " baz"])))

@test md"""```julia
foo
```
""" == MD(Code("julia", "foo"))

@test md"""
* one
* two

1. pirate
2. ninja
3. zombie""" == Markdown.MD([Markdown.List(["one", "two"]),
                             Markdown.List(["pirate", "ninja", "zombie"], true)])

@test md"Foo [bar]" == MD(Paragraph("Foo [bar]"))
@test md"Foo [bar](baz)" != MD(Paragraph("Foo [bar](baz)"))
@test md"Foo \[bar](baz)" == MD(Paragraph("Foo [bar](baz)"))

# Basic plain (markdown) output

@test md"foo" |> plain == "foo\n"
@test md"foo *bar* baz" |> plain == "foo *bar* baz\n"
@test md"#title" |> plain == "# title\n"
@test md"## section" |> plain == "## section\n"
@test md"## section `foo`" |> plain == "## section `foo`\n"
@test md"""Hello

---
World""" |> plain == "Hello\n\n–––\n\nWorld\n"

# HTML output

@test md"foo *bar* baz" |> html == "<p>foo <em>bar</em> baz</p>\n"
@test md"something ***" |> html == "<p>something ***</p>/n"
@test md"``code```more code``" |> html == "<p><code>code```more code</code></p>\n"
@test md"``code``````more code``" |> html == "<p><code>code``````more code</code></p>\n"
@test md"# h1## " |> html == "<h2>h1##</h2>\n"
@test md"## h2 ### " |> html == "<h2>h2</h2>\n"
@test md"###### h6" |> html == "<h6>h6</h6>\n"
@test md"####### h7" |> html == "<p>####### h7</p>\n"
@test md"   >" |> html == "<blockquote>\n</blockquote>\n"
@test md"1. Hello" |> html == "<ol>\n<li>Hello</li>\n</ol>\n"
@test md"* World" |> html == "<ul>\n<li>World</li>\n</ul>\n"
@test md"# title *blah*" |> html == "<h1>title <em>blah</em></h1>\n"
@test md"## title *blah*" |> html == "<h2>title <em>blah</em></h2>\n"
@test md"""Hello

---
World""" |> html == "<p>Hello</p>\n<hr />\n<p>World</p>\n"

# Interpolation / Custom types

type Reference
    ref
end

ref(x) = Reference(x)

ref(fft)

writemime(io::IO, m::MIME"text/plain", r::Reference) =
    print(io, "$(r.ref) (see Julia docs)")

@test md"Behaves like $(ref(fft))" == md"Behaves like fft (see Julia docs)"

# GH tables
@test md"""
    a  | b
    ---|---
    1  | 2""" == MD(Table(Any[["a","b"],
                              ["1","2"]], [:r, :r]))

@test md"""
    | a  |  b | c |
    | :-- | --: | --- |
    | d`gh`hg | hgh**jhj**ge | f |""" == MD(Table(Any[["a","b","c"],
                                                      Any[["d",Code("gh"),"hg"],
                                                          ["hgh",Bold("jhj"),"ge"],
                                                          "f"]],
                                                  [:l, :r, :r]))
t = """a   |   b
:-- | --:
1   |   2
"""
@test plain(Markdown.parse(t)) == t

