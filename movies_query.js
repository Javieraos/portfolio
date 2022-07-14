// Seleccionamos la base de datos a utilizar

use tarea

// Importar los datos y crear la colección (botón Import)

// Consultar el número de documentos

db.movies.find().count()

// Esquema

db.movies.findOne()

// Insertar y eliminar un documento

db.movies.insert({
	"Movie_Title" : "Ejemplo",
	"Released_Year" : 2022,
	"Runtime" : 144,
	"Genre" : [
		"Drama",
		"Crime"
	],
	"IMDB_Rating" : 10,
	"Meta_score" : 99,
	"Director" : "Pepe Perez",
	"Star1" : "Tim Robbins",
	"Star2" : "Morgan Freeman",
	"Star3" : "Bob Gunton",
	"Star4" : "William Sadler",
	"Noofvotes" : 244556,
	"Gross" : 3000709
})

db.movies.update({"Movie_Title" : "Ejemplo"}, {$set:{Meta_score: 90}})

db.movies.find({"Movie_Title": "Ejemplo"})

db.movies.remove({"Movie_Title": "Ejemplo"})

// Valores nulos importantes

db.movies.find({IMDB_Rating: {$exists: false}}).count()
db.movies.find({Meta_score: {$exists: false}}).count()
db.movies.find({Noofvotes: {$exists: false}}).count()
db.movies.find({Gross: {$exists: false}}).count()

// 10 mejores películas IMDB

db.movies.find({}, {_id: 0, Movie_Title: 1, IMDB_Rating: 1})
.sort({ IMDB_Rating: -1 }).limit(10)

// 10 mejores películas Meta_Score

db.movies.find({}, {_id: 0, Movie_Title: 1, Meta_score: 1})
.sort({ Meta_score: -1, IMDB_Rating: -1}).limit(10)

// 10 películas más taquilleras

db.movies.find({}, {_id: 0, Movie_Title: 1, Gross: 1})
.sort({ Gross: -1}).limit(10)

// 10 películas más votadas

db.movies.find({}, {_id: 0, Movie_Title: 1, Noofvotes: 1, IMDB_Rating: 1})
.sort({ Noofvotes: -1}).limit(10)

// 10 películas más largas

db.movies.find({}, {_id: 0, Movie_Title: 1, Runtime: 1, IMDB_Rating: 1})
.sort({ Runtime: -1}).limit(10)

// Número de películas por año

db.movies.aggregate(
    [
        {$unwind: "$Released_Year"},
        {$group: {_id : "$Released_Year", Total: {$sum : 1}}},
        {$sort: {Total : -1}}
        {$limit: 10}
    ])

// Número de películas por director
    
db.movies.aggregate(
    [
        {$unwind: "$Director"},
        {$group: {_id : "$Director", Total: {$sum : 1}}},
        {$sort: {Total : -1}}
        {$limit: 10}
    ])

// Nota media de cada director

db.movies.aggregate(
    [
        {$unwind: "$Director"},
        {$group: {_id : "$Director", Nota_Media: {$avg: "$IMDB_Rating"}, Total: {$sum : 1}}},
        {$sort: {Nota_Media: -1}}
        {$limit: 10}
    ])
    
// Nota media de cada director con mínimo 5 películas

db.movies.aggregate(
    [
        {$unwind: "$Director"},
        {$group: {_id : "$Director", Nota_Media: {$avg: "$IMDB_Rating"}, Total: {$sum : 1}}},
        {$match: {Total: {$gte: 5}}
        {$sort: {Nota_Media: -1}}
        {$limit: 10}
    ])

// Películas de Christopher Nolan

db.movies.aggregate(
    {$match: {Director: "Christopher Nolan"}}
    {$sort: {IMDB_Rating: -1}
    {$project: {_id: 0, Director: 0, Star1: 0, Star2: 0, Star3: 0, Star4: 0}
    )

// Los mejores directores según su recaudación

db.movies.aggregate(
    [
        {$unwind: "$Director"},
        {$group: {_id : "$Director", Recaudación: {$sum: "$Gross"}}},
        {$sort: {Recaudación: -1}}
        {$limit: 10}
    ])

// Mejores actores según su recaudación

db.movies.aggregate(
    [
        {$unwind: "$Star1"},
        {$group: {_id : "$Star1", Recaudación: {$sum: "$Gross"}}},
        {$sort: {Recaudación: -1}}
        {$limit: 10}
    ])

// Los géneros mejor valorados

db.movies.aggregate(
    [
        {$unwind: "$Genre"},
        {$group: {_id : "$Genre", Nota_Media: {$avg: "$IMDB_Rating"}, Total: {$sum : 1}}},
        {$sort: {Nota_Media: -1}}
        {$limit: 10}
    ])

// Géneros que más han recaudado

db.movies.aggregate(
    [
        {$unwind: "$Genre"},
        {$group: {_id : "$Genre", Recaudación: {$sum : "$Gross"}}},
        {$sort: {Recaudación: -1}}
        {$limit: 10}
    ])

