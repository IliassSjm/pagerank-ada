with Ada.IO_Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Command_line; use Ada.Command_line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

generic

   Capacite : Integer;
   --type T_Element is digits <>;


package G_naive is

   --PRECISION : Constant Integer := 6;
   --type T_Double is digits PRECISION;

   type T_Vecteur_Pour_Tri is array(Integer range <>) of float;
   type T_Vecteur is array( 1..Capacite) of float;
   type T_Matrice is array( 1..Capacite) of T_Vecteur;
   type T_Indices is array(1..Capacite) of Integer;


   Procedure Initialiser_G(G: out T_Matrice);

   Procedure Initialiser_Indices(Indices: out T_Indices);

   Procedure Initialiser_Vecteur_Poids(Vecteur_Poids: out T_Vecteur)
     with Post => Taille(Vecteur_Poids) = Capacite;

   function Taille(Vecteur_Poids: in T_Vecteur) return Integer with
    Post => Taille'Result >= 0;

   procedure Calculer_Vecteur_Poids(Vecteur_Poids:in out T_Vecteur; Iterations: in Integer ; G: in T_Matrice; Nombre_Pages: in Integer);

   procedure Construire_G( G:in out T_Matrice; alpha: in Float; adresse: Unbounded_String);

   procedure Recuperer_Bon_Ordre(Numero_Page, Numero_Page_Pointee: out Integer ; ordre: in Integer; File: in Ada.Text_IO.File_Type);

   procedure Tri_Poids(Vecteur_Poids_pour_tri: in out T_Vecteur_Pour_Tri; Indices:in out T_Indices);


   procedure Afficher(Vecteur_Poids: in T_Vecteur);

   procedure Conversion_Type(Vecteur_Poids: in T_Vecteur; Vecteur_Poids_pour_tri: out T_Vecteur_Pour_Tri);

   procedure Ecriture_Fichiers(Vecteur_Poids_pour_tri:in T_Vecteur_Pour_Tri; Indices: in T_Indices; adresse: in Unbounded_String; alpha: in Float; Iterations: In Integer);

end G_naive;
