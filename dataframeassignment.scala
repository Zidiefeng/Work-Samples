package edu.wm.ktsun

import org.apache.spark._
import org.apache.spark.SparkContext._
import org.apache.spark.sql._
import org.apache.log4j._
import scala.io.Source
import java.nio.charset.CodingErrorAction
import scala.io.Codec
import org.apache.spark.sql.functions._
import java.io._

object dataframeassignment {

//  Set a class with format [MovieID,Rating]
  case class Movie(MovieID:Int, Rating:Int)

//  Function to load names
  def loadMovieNames() : Map[Int, String] = {
    implicit val codec = Codec("UTF-8")
    codec.onMalformedInput(CodingErrorAction.REPLACE)
    codec.onUnmappableCharacter(CodingErrorAction.REPLACE)
    var movieNames:Map[Int, String] = Map()
    val lines = Source.fromFile("../ml-100k/u.item").getLines()
    for (line <- lines) {
       var fields = line.split('|')
       if (fields.length > 1) {
        movieNames += (fields(0).toInt -> fields(1))
       }
     }
     return movieNames
  }
 

//  Function to extract data from file
  def mapper(line:String): Movie = {
    val fields = line.split("\t")
    val movie:Movie = Movie(fields(1).toInt, fields(2).toInt)
    return movie
  }
 
  
  def main(args: Array[String]) {
   
    Logger.getLogger("org").setLevel(Level.ERROR)
    
    val spark = SparkSession
      .builder
      .appName("SparkSQL")
      .master("local[*]")
      .config("spark.sql.warehouse.dir", "file:///C:/temp") 
      .getOrCreate()
      
//  read data from file and store as dataset
    import spark.implicits._
    val lines = spark.sparkContext.textFile("../ml-100k/u.data")
    val movieDS = lines.map(mapper).toDS().cache()
    
    println("Here is our inferred schema:")
    movieDS.printSchema()
    movieDS.createOrReplaceTempView("movie")


//  Use query to do the required task
    val movie = spark.sql("""
                               SELECT MovieID,count(*),avg(Rating)
                               FROM movie 
                               GROUP BY MovieID
                               HAVING count(*) >= 100
                               ORDER BY 3
                               """)
    val results = movie.collect() 

    results.foreach(println)
    println(movie)
    
//    Write to a output file
    val names = loadMovieNames()
    val file = "Assignment5.txt"
    val writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file)))
    for (x <- results) {writer.write(names(x(0).asInstanceOf[Int]) + "    "+x(1)+"    "+x(2)+ "\n")}
    writer.close()
    
//    Stop spark
    spark.stop()
    }
}
      
      
      

      

    
    
    
    
    
    
    
    
    
    
    