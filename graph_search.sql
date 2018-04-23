/*
The first step is to create a table which defines a graph.

The id attribute defines the current node. The neighbor attribute contains the id of a node reachable from
the current node. The arc cost field contains the cost of transitioning from the current node to the 
neighboring node.
*/
CREATE TABLE NODES (
  ID 		int 	NOT NULL,
  ARC_COST 	decimal,
  NEIGHBOR 	int
);

/*
Create a graph which has the following structure.
  
  2
 / \
1 | 4
 \ /
  3

The edges are directed in the following manner.

1->2
1->3
2->3
2->4
3->4
*/
INSERT INTO NODES VALUES (1, 1.0, 2);
INSERT INTO NODES VALUES (1, 2.0, 3);
INSERT INTO NODES VALUES (2, 2.0, 4);
INSERT INTO NODES VALUES (3, 0.5, 4);
INSERT INTO NODES VALUES (2, 5.0, 3);
INSERT INTO NODES VALUES (4, 0.0, NULL);

/*
The following is the common table expression which allows for the recursive query to be formed.
*/
WITH RECURSIVE CTE_GRAPH_SEARCH (ID, ARC_COST, NEIGHBOR, TOTAL_COST, PATH_LENGTH) AS (
	--anchor statement
	SELECT ID, ARC_COST, NEIGHBOR, ARC_COST AS TOTAL_COST, 0 AS PATH_LENGTH
	FROM NODES
	WHERE ID=1
	
    UNION ALL
	
	--recursive statement
    SELECT NODES.ID, NODES.ARC_COST, NODES.NEIGHBOR, CTE_GRAPH_SEARCH.TOTAL_COST + NODES.ARC_COST, CTE_GRAPH_SEARCH.PATH_LENGTH + 1
	FROM CTE_GRAPH_SEARCH
	INNER JOIN NODES
	ON CTE_GRAPH_SEARCH.NEIGHBOR = NODES.ID
	--stopping condition which prevents infinite recursion when a cycle exists in the graph
	WHERE CTE_GRAPH_SEARCH.PATH_LENGTH < 100
) 

/*
Find the minimum cost path from the source node specified in the anchor statement 
to all other reachable nodes.
*/
select NEIGHBOR, min(TOTAL_COST)
from CTE_GRAPH_SEARCH
where NEIGHBOR is not null
group by NEIGHBOR

/*
Determine if there is a connection between the node listed in the CTE's 
anchor statement and the node listed in the where condition of the below 
derived table.
*/
select 
case when count(*) > 0 then 1 else 0 end as PATH_EXISTS
from (
	Select 
	id 
	from CTE_GRAPH_SEARCH
	/* 
	This is the node to which we are checking if a path exists.
	*/
	where id = 4
) sub




