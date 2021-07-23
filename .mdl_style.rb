# mdl rules https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md

# Import all default rules
all

# Only allow atx style headings (e.g. # H1 ## H2)
rule 'MD003', :style => :atx

# Only allow dashes in unordered lists
rule 'MD004', :style => :dash

# Enforce line length of 80 characters except in code blocks and tables
rule 'MD013', :code_blocks => false, :tables => false

# Ignore blockquotes separated only be a blank line. This is a limitation of
# some markdown parsers, not markdown itself.
exclude_rule 'MD028'

# Allow bare URLs (i.e. without angle brackets)
exclude_rule 'MD034'
