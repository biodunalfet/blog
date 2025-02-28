---
title: "study notes - the art of postgresql by dimitri fontaine"
date: 2025-01-13T06:02:25+01:00
draft: false
tags:
    - books
---

### **Context**
I needed to do some migration from MongoDB to PostgreSQL for a thing I was building. Even though I'd used Postgres at work,
we never really got to run complex queries (in code) or work on features that tested the limits of my knowledge. To cut the
long story short, I decided to take the time to better understand PostgreSQL and its key features.

After some digging through subreddits and Hacker News, I decided on studying 3 books:

1. [The Art of PostgreSQL by Dimitri Fontaine](https://theartofpostgresql.com/) ✅
2. [SQL performance explained by Markus Winand](https://use-the-index-luke.com/)
3. [A Curious Mind by Rob Conery](https://sales.bigmachine.io/curious-moon)

---
#### **key concepts and some best practices**

<br>
<br>
<details>
  <summary><b>JOIN Syntax and Best Practices</b></summary>

- Use `USING(column)` when joining tables with matching column names (more concise)
```postgresql
SELECT * FROM orders
JOIN customers USING(customer_id);  -- When both tables have customer_id column
```
- Use `ON table_a.column = table_b.column` when:
  - Joining tables with different column names
  - Need more complex join conditions
```
SELECT * FROM orders o
JOIN customers c ON o.cust_id = c.customer_id;  -- Different column names
```
</details>
<br>
<details>
<summary><b>Query Testing and Validation</b></summary>

- `RegreSQL` can be used to create regression tests for your queries
- Regression tests help ensure query behavior remains consistent across database changes
</details>
<br>
<details>
<summary><b>Indexing Strategy and Trade-offs</b></summary>

- Different types of indexes serve different query patterns
- Indexes have a cost for DML (Data Manipulation Language) operations:
  - `INSERT` operations need to update indexes
  - `UPDATE` operations may need to modify multiple index entries
  - `DELETE` operations need to remove index entries
- Some indexes are mandatory for data consistency:
  - `UNIQUE`, `PRIMARY KEY` and `EXCLUDE USING` constraints all require an index
- Benefits of proper indexing:
  - Faster data access
  - Improved query performance
  - Better data retrieval patterns
</details>
<br>
<details>
<summary><b>Query Optimization and Analysis</b></summary>

- Single Query vs Multiple Queries
  - Complex business logic can often be handled more efficiently with a single PostgreSQL query rather than multiple queries with application-level processing
  - Network latency typically forms the bulk of request completion time, making single queries more efficient
  - Databases are optimized to handle complex queries efficiently, leveraging built-in query planning and optimization
- Use `pg_stat_statements` to understand query usage statistics. This extension helps with query optimization by showing which indexes to add and how to structure them
- Avoid `SELECT` * as it:
  - Retrieves more rows than needed
  - Utilizes unnecessary network bandwidth
  - Can break application code during deserialization if column names change
- `LATERAL JOIN`: Functions similarly to a foreach loop
- `DISTINCT ON`: Equivalent to using GROUP BY but picks the first result of each group. Important to use ORDER BY when needed for your use case

For example, these two queries return the same results (first name and last name of drivers who have ever won an F1 race):

```sql
select distinct on(driverid) forename, surname from results
join drivers using(driverid)
where position = 1

select min(forename), min(surname) from results 
join drivers using(driverid)
where position = 1
group by driverid
```
</details>
<br>
<details>
<summary><b>Pagination and Performance</b></summary>

- Avoid using `OFFSET` as it scans through all rows before filtering out specified values
- Standard SQL offers `FETCH` instead of `OFFSET` and `LIMIT`
- Better pagination can be achieved using index lookups (`row()`) with properly indexed columns
- Use `EXPLAIN ANALYZE` to understand query performance (helpful visualization tool: https://pev2.pages.dev/)
</details>
<br>
<details>
<summary><b>Grouping Operations</b></summary>

- `HAVING`: Acts like WHERE but applies to group results instead of individual rows
- `GROUPING SETS`: Concise way to merge results of multiple groupings in one query
- `ROLL UP`: Generates grouping sets from most granular to least granular. For example:
```postgresql
GROUP BY ROLLUP(A, B, C) = GROUP BY GROUPING SETS((A, B, C), (A, B), (A), ())
```
- `CUBE`: Similar to ROLL UP but creates complete permutations of provided columns:
```postgresql
GROUP BY CUBE(A, B, C) = GROUP BY GROUPING SETS((A, B, C), (A, B), (A, C), (B, C), (A), (B), (C), ())
```
</details>
<br>
<details>
<summary><b>Set Operations</b></summary>

- `UNION ALL`: Concatenates result sets (must have matching column types and count)
- `UNION`: Same as `UNION ALL` but removes duplicates (slower)
- `EXCEPT`: Excludes results of second query from first query
- `INTERSECT`: Returns results present in both queries
</details>
<br>
<details>
<summary><b>Window Functions and Rankings</b></summary>

Structure for window functions:
```postgresql
[function you want to apply] OVER (
  [PARTITION BY column_list]  -- Optional 
  [ORDER BY column_list]      -- Optional 
  [frame_clause]              -- Optional 
)

-- e.g Calculating Running Totals within Groups

SELECT
customer_id,
order_date,
amount,
SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders;
```
- popular [aggregate functions](https://www.postgresql.org/docs/9.2/functions-aggregate.html) that can be used over a window frame definition
- general purpose in-built [window function](https://www.postgresql.org/docs/9.2/functions-window.html)
> Use window functions whenever you want to compute values for each row of the
> result set and those computations depend on other rows within the same result
> set.
- `RANK()`: Assigns rankings within partitioned data
```postgresql
SELECT product_name,
       category,
       price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) as price_rank
FROM products;
```
</details>
<br>
<details>
<summary><b>NULL Handling</b></summary>

- Use `IS DISTINCT FROM` or `IS NOT DISTINCT FROM` for null comparisons instead of `=` or `<>`
- Remember three-valued logic with nulls:
  - `null = true` evaluates to `null` 
  - `x` `IS NULL` is not the same as `x = null`
  - Three-valued logic truth table for `NULL` comparisons:
  | left | right |  =  |  <> | "is distinct" | "is not distinct from" |
    |---|---|---|---|---|---|
  | true | true | true | false | false | true |
  | true | false | false | true | true | false |
  | true | `null` | `null` | `null` | true | false |
  | false | true | false | true | true | false |
  | false | false | true | false | false | true |
  | false | `null` | `null` | `null` | true | false |
  | `null` | true | `null` | `null` | true | false |
  | `null` | false | `null` | `null` | true | false |
  | `null` | `null` | `null` | `null` | false | true |
</details>
<br>
<details>
<summary><b>Useful Built-in Functions</b></summary>

- `generate_series()`: Creates a series of values
```postgresql
-- Generate dates for each day in January
SELECT generate_series(
'2024-01-01'::date,
'2024-01-31'::date,
'1 day'::interval
);
```
- Date/Time Functions:
  - `extract()`: Extracts specific parts of a date/time value
  - `to_char()`: Formats dates and numbers as strings
  - `date_trunc()`: Truncates date/time values to specified precision

```postgresql
SELECT
extract(YEAR FROM timestamp '2024-01-13'),
to_char(timestamp '2024-01-13', 'Month DD, YYYY'),
date_trunc('month', timestamp '2024-01-13');
```

- `CASE`: Adds conditional logic in queries
```postgresql
SELECT
product_name,
price,
CASE
WHEN price < 100 THEN 'Budget'
WHEN price < 500 THEN 'Mid-range'
ELSE 'Premium'
END as price_category
FROM products;
```
</details>

#### **data types**
<br>
<br>
<details>
<summary><b>Arrays</b></summary>

- PostgreSQL supports arrays of any built-in or user-defined type
- Useful for denormalized data structures where appropriate
- Key array operations:
  - `unnest(column):` Expands an array into a set of rows
```postgresql
-- Example: Converting an array of tags into separate rows
  SELECT id, unnest(tags) as tag
  FROM posts
  WHERE tags IS NOT NULL;
```
- Particularly useful for:
  - Querying individual array elements
  - Joining array elements with other tables
  - Aggregate operations on array elements
- Can help avoid junction tables in some cases, though normalization is still preferred for most relationships

</details>
<br>

<details>
<summary><b>Boolean</b></summary>

- Use `IS` to test against literal true, false, and null rather than `=`
- Can be aggregated with `bool_and` and `bool_or`
</details>
<br>
<details>
<summary><b>Character and Text</b></summary>

- `text` and `varchar` are identical in PostgreSQL
- `character varying` is an alias for `varchar`
- `varchar(X)` is a text column with a check constraint of X characters
- Useful functions: `regexp_split_to_table()` and `regexp_split_to_array()`
- `regexp_matches`: Extract pattern matches from strings
```postgresql
-- Example: Extract all email addresses from a text column
SELECT regexp_matches(description, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', 'g')
FROM documents;
```
</details>
<br>
<details>
<summary><b>Numeric Types</b></summary>

- Available types
  - `integer`: 32-bit signed numbers
  - `bigint`: 64-bit signed numbers
  - `smallint`: 16-bit signed numbers
  - `numeric`: arbitrary precision numbers
  - `real`: 32-bit floating point (6 decimal digits precision)
  - `double precision`: 64-bit floating point (15 decimal digits precision)
- Given [how floating points are stored in computers](https://floating-point-gui.de/), never use `real` or `double precision` for monetary values
</details>
<br>

<details>
<summary><b>Auto-incrementing IDs and UUIDs</b></summary>

- Prefer `bigserial` over `serial` for new applications to avoid overflow issues
- `serial` is a pseudo-type backed by an `integer`
- When using `serial`, PostgreSQL automatically creates a backing sequence and picks values from it:
```postgresql
  CREATE TABLE tablename (colname SERIAL);

-- This is equivalent to:

CREATE SEQUENCE tablename_colname_seq;  -- backing sequence is created
CREATE TABLE tablename (
colname integer NOT NULL DEFAULT nextval('tablename_colname_seq')
);  -- column values are picked from the sequence
ALTER SEQUENCE tablename_colname_seq OWNED BY tablename.colname;
```
- Be cautious: The backing sequence uses `bigint`, but `serial` uses `integer`, which can lead to overflow issues

</details>
<br>

<details>
<summary><b>UUIDs</b></summary>

- Use the UUID data type instead of text for storing UUIDs
- More memory efficient than storing UUIDs as text
- Provides better type safety and validation
</details>
<br>
<details>
<summary><b>Binary Data Storage (bytea)</b></summary>

- PostgreSQL's bytea type can store binary data (like images)
- Not recommended for:
  - Large files
  - High volume of binary data
- Limitations:
  - No native chunking API
  - Can impact database performance
- Use case: When you specifically need transactional properties for your binary data

</details>
<br>
<details>
<summary><b>Date/Time</b></summary>

- Always use timestamps with time zones
- PostgreSQL uses `bigint` internally for timestamp storage
- ISO format is preferred for timestamp input:
```postgresql
  select timestamptz '2017-01-08 04:05:06',
  timestamptz '2017-01-08 04:05:06+02';
```
- Interval arithmetic is straightforward
```postgresql
    interval '[numberic value] [time period]' 
    -- e.g
    interval '1 month'

select d::date as month,
       (d + interval '1 month' - interval '1 day')::date as month_end,
       (d + interval '1 month')::date as next_month,
       (d + interval '1 month')::date - d::date as days

from generate_series(
             date '2017-01-01',
             date '2017-12-01',
             interval '1 month')
       as t(d);

-- the query above shows how mnay days are in the months of the year 2017
```  
</details>
<br>
<details>
<summary><b>JSON and JSONB</b></summary>

- JSON is stored as text with format validation
- JSONB offers binary storage with:
  - Full indexing capabilities
  - Advanced searching and processing
  - Single value per key restriction
- Best practice: Use traditional columns for static data and JSONB for flexible, occasional-use data
</details>
<br>
<details>
<summary><b>Enums</b></summary>

- PostgreSQL supports enum types
- Best practice: Use a reference table instead of enum types
  - Creates a table with ID and values
  - More flexible for future modifications
  - Can be referenced from other tables

</details>
<br>

#### **business logic in db**
<br>
<br>
<details>
<summary><b>Check Constraints</b></summary>

- Add business rules directly in the database schema
- Examples:
```postgresql
-- Simple check constraint
CREATE TABLE products (
product_no integer,
name text,
price numeric CHECK (price > 0)
);

-- Multiple check constraints
CREATE TABLE products (
product_no integer,
name text,
price numeric CHECK (price > 0),
discounted_price numeric,
CHECK (discounted_price > 0 AND price > discounted_price)
);
```
</details>
<br>

<details>
<summary><b>Using Domains</b></summary>

- Create reusable data types with built-in constraints
- Useful for consistent validation across tables
```postgresql
-- Create a domain for positive integers
CREATE DOMAIN PositiveInteger AS INTEGER
CHECK (VALUE > 0);

-- Use the domain in a table
CREATE TABLE People (
id SERIAL PRIMARY KEY,
name TEXT,
age PositiveInteger  -- Using domain instead of plain integer
);
```
</details>
<br>

<details>
<summary><b>Custom Types and Constraints</b></summary>

```postgresql
-- Define a composite type
CREATE TYPE address AS (
  street TEXT,
  city TEXT,
  zip_code VARCHAR(10)
);

-- Use the composite type in a table
CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  name TEXT,
  billing_address address
);

INSERT INTO customer (name, billing_address)
VALUES ('John Doe', ROW('123 Main St', 'Anytown', '12345'));
```
</details>
<br>

#### **antipatterns to avoid**
<br>
<br>
<details>
<summary><b>Entity-Attribute-Value (EAV)</b></summary>

Problems include:

- No data type constraints (all values stored as text)
- Susceptible to typos in entity and parameter fields
- Difficult to query and interpret results
- **Solution**: Use proper modeling with JSONB for extension points
</details>
<br>

<details>
<summary><b>Multiple Values per Column</b></summary>

Instead of storing multiple values in a text field (e.g., hashtags), use PostgreSQL arrays for better searching and sorting capabilities.
</details>
<br>

#### **other features and considerations**
<br>
<br>

<details>
<summary><b>Partitioning</b></summary>

Trade-offs include:
  - Need for per-partition indexes
  - Foreign key relationship limitations
  - Benefits from partition pruning often outweigh limitations
</details>
<br>

<details>
<summary><b>Concurrency and Transactions</b></summary>

- Default isolation level is "read committed"
- Consider concurrency behavior in data modeling
- Avoid designs that create competition for single shared resources
- Batch updates need careful handling to prevent lost updates
</details>
<br>

<details>
<summary><b>Views and Materialized Views</b></summary>

- Views hide query complexity
- Materialized Views cache results but need periodic refreshing
- Consider setting up CRON jobs for materialized view refreshes
</details>
<br>

<details>
<summary><b>Event Handling</b></summary>

- Triggers run within transactions but can create bottlenecks
- `LISTEN/NOTIFY` provides event-driven capabilities but:
  - Requires active connections
  - Not suitable for event accumulation
  - Works well for notification-driven query refreshes
</details>
<br>

---

### **final thoughts**
This book transformed my view of databases. I now see them as fully-qualified services that are primarily optimized for data storage and retrieval but capable of much more. I'll definitely be spending more time deepening my knowledge of databases.

### **things I didn't like about this book**
- It contained numerous typos
- Required frequent context switching across different datasets (Twitter, F1, geonames, pubnames, etc.)
- Some key dataset links were broken

