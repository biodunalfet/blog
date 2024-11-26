---
title: "database internals: a brief look at h2's tokeniser"
date: 2024-11-19T01:01:57+01:00
draft: false
tags:
    - database
---

### Introduction 
I recently became fascinated by databases. It occurred to me that they are essential components across all areas of software
development, existing in various forms and playing critical roles in countless applications. That got me on the path to 
digging into its internals.

I started out by re-building a mini version of SQLite using Kotlin (more on that in a future post). However, I encountered performance 
issues when querying indexed fields in a large SQLite file. While I could locate the indexes efficiently using the B+ tree structure, 
retrieving the actual data entries was very slow.

To get a better understanding of how data retrieval works, I decided it was time to look into how this bit was implemented. I tried to 
study the actual sqlite implementation, but I found it a bit overwhelming. It was a **LOT** of **C** code. I hadn't written 
or read **C** in almost a decade, since uni. Also, setting it up took a while. I had to download CLion, figure out 
how to setup the amalgamated version of SQLite and get it to play nicely with the IDE, among other things

Thankfully, **H2** came to the rescue. It's a fairly popular, lightweight db that runs on the JVM. It is used more on the backend and
to a lesser degree on Android. It is commonly used in embedded mode but can run in server mode too.

I pulled the code, and it was impressive: thousands of lines of clear, easy-to-follow Java. I was able to set it up in less than 
5 minutes and started to debug with breakpoints and tests.

### The Tokenizer
When a SQL statement is run on a db engine, the input string has to be parsed into a query tree.
The input string is split into "chunks" called tokens. H2 supports 11 types of tokens, the main ones being;

1. `IdentifierToken` - An identifier is a token that forms a [name](https://github.com/h2database/h2database/blob/d2c2b322592bd66f7428d7b230fa7bab15e128de/h2/src/main/org/h2/util/ParserUtil.java#L18)
e.g a table name or column name.
2. `KeywordToken` - Keyword tokens are the reserved words that have a special meaning to the SQL parser. They cannot be used 
as identifiers (such as table names or column names) unless they are quoted .e.g `"TABLE", "PRIMARY", "SELECT"`. You can find a list of
keywords as identified by h2 [here](https://github.com/h2database/h2database/blob/d2c2b322592bd66f7428d7b230fa7bab15e128de/h2/src/main/org/h2/util/ParserUtil.java#L484-L587)

There are "literal" types which represent fixed values that appear directly in your SQL queries. Examples of these are
`IntegerToken`, `CharacterStringToken`, `BigintToken` and `BinaryStringToken` which as their names imply, hold tokens whose values are integers or regular strings or binary strings.

There's also the `EndOfInputToken` which marks the end of a stream of tokens.

The classification of tokens is straightforward. By default, if a token is in the list of keywords defined in [ParserUtils]((https://github.com/h2database/h2database/blob/d2c2b322592bd66f7428d7b230fa7bab15e128de/h2/src/main/org/h2/util/ParserUtil.java#L484-L587))
, they're categorised as `KeywordToken`. Otherwise, they're set to be `IdentifierToken`, if they're not one of the literal types.


### The Process, Briefly
The tokenization process in H2 starts by initializing an array to store the identified tokens. It then iterates through the SQL string, character by 
character. For each character, it checks for the presence of delimiters like spaces or parentheses to identify the end of a token. Once a token is identified,
it's categorized as either a keyword (like "CREATE" or "TABLE") or an identifier (like table or column names). The process also handles various literal types,
such as integers and strings, using specialized functions for different formats. Finally, after processing all characters, the tokenizer appends an `EndOfInputToken`
to the array and returns the complete list of tokens.

```java 
    ArrayList<Token> tokenize(String sql, boolean stopOnCloseParen, BitSet parameters) {
        ArrayList<Token> tokens = new ArrayList<>();
        int end = sql.length() - 1;
        boolean foundUnicode = false;
        int lastParameter = 0;
        loop: for (int i = 0; i <= end;) {
            char c = sql.charAt(i);
            Token token;
            switch (c) { ...over 100 lines of cases... }
            tokens.add(token);
            i++;
        }
        if (foundUnicode) {
            processUescape(sql, tokens);
        }
        tokens.add(new Token.EndOfInputToken(end + 1));
        return tokens;
    }
```

I encourage you to check out the full `Tokenizer.tokenize()` [function](https://github.com/h2database/h2database/blob/d2c2b322592bd66f7428d7b230fa7bab15e128de/h2/src/main/org/h2/command/Tokenizer.java#L162-L176) 
to see how it all works end-to-end.

### Examples
Using 3 very simple but common sql statements, here's how the tokens are resolved.
1. `create table test(id int primary key, name varchar(255))`

Token | Type
--------|------
`create` | `org.h2.command.Token$IdentifierToken`
`table` | `org.h2.command.Token$KeywordToken`
`test` | `org.h2.command.Token$IdentifierToken`
`(` | `org.h2.command.Token$KeywordToken`
`id` | `org.h2.command.Token$IdentifierToken`
`int` | `org.h2.command.Token$IdentifierToken`
`primary` | `org.h2.command.Token$KeywordToken`
`key` | `org.h2.command.Token$KeywordToken`
`,` | `org.h2.command.Token$KeywordToken`
`name` | `org.h2.command.Token$IdentifierToken`
`varchar` | `org.h2.command.Token$IdentifierToken`
`(` | `org.h2.command.Token$KeywordToken`
`255` | `org.h2.command.Token$IntegerToken`
`)` | `org.h2.command.Token$KeywordToken`
`)` | `org.h2.command.Token$KeywordToken`
end-of-string | `org.h2.command.EndOfInputToken`

--- 

2. `insert into test values(1, 'Hello')`

Token | Type
--------|------
`insert` | `org.h2.command.Token$IdentifierToken`
`into` | `org.h2.command.Token$IdentifierToken`
`test` | `org.h2.command.Token$IdentifierToken`
`values` | `org.h2.command.Token$KeywordToken`
`(` | `org.h2.command.Token$KeywordToken`
`1` | `org.h2.command.Token$IntegerToken`
`,` | `org.h2.command.Token$KeywordToken`
`Hello` | `org.h2.command.Token$CharacterStringToken`
`)` | `org.h2.command.Token$KeywordToken`
end-of-string | `org.h2.command.EndOfInputToken`

---

3. `select * from test`

Token | Type
--------|------
`select` | `org.h2.command.Token$KeywordToken`
`*` | `org.h2.command.Token$KeywordToken`
`from` | `org.h2.command.Token$KeywordToken`
`test` | `org.h2.command.Token$IdentifierToken`
end-of-string | `org.h2.command.EndOfInputToken`

### Easter Eggs? 😉
I found a couple of interesting tricks while studying the code

1. Using a bitwise `AND` operation to convert a character to uppercase, using `0xffdf` as a bitmask 

```java
 private Expression readTermWithIdentifier(String name, boolean quoted) {
    /*
     * Convert a-z to A-Z. This method is safe, because only A-Z
     * characters are considered below.
     *
     * Unquoted identifier is never empty.
     */
    switch (name.charAt(0) & 0xffdf) {
    case 'C':
    ...
```

2. Labelled loops, which allows for easy mixing of switch and for statements. You know `break` can break from both `switch` and `for-loops`.
To break from the loop, you have to do `break loop` instead of just `break` which marks the end of a condition in the `switch` statement. 

```java
 case ')':
    token = new Token.KeywordToken(i, CLOSE_PAREN);
    if (stopOnCloseParen) {
        tokens.add(token);
        end = skipWhitespace(sql, end, i + 1) - 1;
        break loop;
    }
    break;
...
```

3. For chars `'0' - '9'`, you can get its equivalent integer representation by subtracting `'0'` from it

```java
 }
number = number * 10 + (c - '0');
if (number > Integer.MAX_VALUE) {
```

The characters `'0', '1', '2'` have the ASCII values of `48, 49 and 50` respectively. A neat yet efficient way to convert 
numeric chars into their integer equivalents is to subtract `'0'` from them. This avoids the overhead of string-to-integer operations

```java
'1' - '0' => 49 - 48 = 1
'2' - '0' => 50 - 48 = 2
```


---
<ins>**References**</ins>
- [Database Design and Implementation - Edward Sciore](https://www.amazon.co.uk/Database-Design-Implementation-Data-Centric-Applications/dp/3030338355)
- H2 Database, the Java SQL database - https://github.com/h2database/h2database

<br/><br/>
_In my next post, I'll explain how these tokens are interpreted and converted by the engine into executable commands._