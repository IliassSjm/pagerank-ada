with Ada.IO_Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Command_line; use Ada.Command_line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

generic

    Capacite : Integer;
    type Index is (<>);

package g_creuse is


    -- Création de 3 listes pour enregistrer la matrice creuse :
    -- A prend les valeurs non nulles de la matrice.
    -- IA prend la somme par ligne du nombre de valeur non nulles.
    -- JA prend le numéro de la colonne des valeurs non nulles enregistrées dans A
    type T_Creuse is limited private;

    type T_Vecteur is array( 1..Capacite) of float;
    type T_Vecteur_Pour_Tri is array(Integer range <>) of float;
    type T_Matrice is array( 1..Capacite) of T_Vecteur;
    type T_Indices is array(1..Capacite) of Integer;

    procedure Initialiser_Creuse(A: out T_Creuse) with
            Post => Est_Vide (A);

    procedure Initialiser_Vecteur_Poids(Vecteur_Poids: out T_Vecteur)
            with Post => Taille(Vecteur_Poids) = Capacite;

    procedure Initialiser_Indices(Indices: out T_Indices);

    procedure Initialiser_G(G: out T_Matrice);

    function Est_Vide (A : in T_Creuse) return Boolean;

    function Taille (Vecteur_Poids: in T_Vecteur) return Integer
            with Post => Taille'Result >= 0;

    function Taille (A : in T_Creuse) return Integer;

    procedure Afficher(G: in T_Matrice);

    procedure Afficher(Vecteur_Poids: in T_Vecteur);

    procedure Conversion_Type(Vecteur_Poids: in T_Vecteur; Vecteur_Poids_pour_tri: out T_Vecteur_Pour_Tri);

    procedure Recuperer_Bon_Ordre(Numero_Page, Numero_Page_Pointee: out Integer ; ordre: in Integer; File: in Ada.Text_IO.File_Type);

    procedure Enregistrer (A : in out T_Creuse; Valeur : in Float; Indicei : in Integer; Indicej : in Integer);

    function La_Donnee (A : in T_Creuse ; Indicei : in Integer; Indicej : in Integer) return Float;

    procedure Construire_A(A: in out T_Creuse; adresse: Unbounded_String);

    procedure Construire_G(G:in out T_Matrice; alpha: in Float; A: in T_Creuse; IA: in T_Creuse; JA: in T_Creuse; adresse : Unbounded_String);

    procedure Calculer_Vecteur_Poids(Vecteur_Poids:in out T_Vecteur; Iterations: in Integer ; G: in T_Matrice; Nombre_Pages: in Integer);

    procedure Tri_Poids(Vecteur_Poids_pour_tri: in out T_Vecteur_Pour_Tri; Indices:in out T_Indices);

    procedure Ecriture_Fichiers(Vecteur_Poids_pour_tri:in T_Vecteur_Pour_Tri; Indices: in T_Indices; adresse: in Unbounded_String; alpha: in Float; Iterations: In Integer);


private

    type T_Cellule is record
        Valeur : Float;
        Indicei : Integer;
        Indicej : Integer;
        Suivant : T_Creuse;
    end record;

    type T_Creuse is access T_Cellule;

end g_creuse;
