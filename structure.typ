// Frontmatter

#include "./preface/firstpage.typ"
#include "./preface/copyright.typ"
// #include "./preface/dedication.typ"
// #include "./preface/summary.typ"
#include "./preface/acknowledgements.typ"
#include "./preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)

#include "./chapters/introduction.typ"
#include "./chapters/preliminary.typ"
#include "./chapters/original-contribution.typ"
#include "./chapters/conclusion.typ"

// // Appendix

// #include "./appendix/appendice-a.typ"

// // Backmatter

// // Praticamente il glossario

// Bibliography

#include("./appendix/bibliography/bibliography.typ")
