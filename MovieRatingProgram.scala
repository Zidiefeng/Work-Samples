package edu.wm.ktsun
import org.apache.spark._
import org.apache.spark.SparkContext._
import org.apache.log4j._
import scala.io.Source
import java.nio.charset.CodingErrorAction
import scala.io.Codec
import java.io._


object MovieRatingProgram {
  def parseLine(line: String) = {
      val fields = line.split("\t")
      val movieID = fields(1).toInt
      val rating = fields(2).toInt
      (movieID, rating)
  }
  def main(args: Array[String]) {
     /** Load up a Map of movie IDs to movie names. */
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
    Logger.getLogger("org").setLevel(Level.ERROR)
    val sc = new SparkContext("local[*]", "MovieRatingProgram")
    var nameDict = sc.broadcast(loadMovieNames)
    val lines = sc.textFile("../ml-100k/u.data")
    val rdd = lines.map(parseLine)
    val totalsByMovie = rdd.mapValues(x => (x, 1)).reduceByKey( (x,y) => (x._1 + y._1, x._2 + y._2))
    val averagesByMovie =  totalsByMovie.mapValues( x =>(x._1.toDouble /x._2.toDouble,x._2))
    val MoviesWithNames = averagesByMovie.map( x  => (nameDict.value(x._1), x._2))
    val MoviesFiltered = MoviesWithNames.filter(_._2._2>=100)
    val flipped = MoviesFiltered.map(x => (x._2._1, (x._1,x._2._2) ))    
    val sortedMovies = flipped.sortByKey()
    val flipped2 = sortedMovies.map(x => (x._2._1, (x._1,x._2._2) ))
    val results = flipped2.collect()
    //results.foreach(println)
    val file = "MovieRatingProgram.txt"
    val writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file)))
    for (x <- results) {writer.write(x._1 + "    "+x._2._1+"    "+x._2._2+ "\n")}
    writer.close()    
  }
    
}
  