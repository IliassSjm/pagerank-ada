with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body g_naive is

   procedure Initialiser_Vecteur_Poids(Vecteur_Poids: out T_Vecteur) is
   begin
      for i in 1..Capacite loop
         Vecteur_Poids(i):=1.0/Float(Capacite);
      end loop;
   end Initialiser_Vecteur_Poids;

   Procedure Initialiser_Indices(Indices: out T_Indices) is
   begin
      for i in 1..Capacite loop
         Indices(i):=i;
      end loop;
   end Initialiser_Indices;

   procedure Initialiser_G( G: out T_Matrice) is
   begin
      for j in 1..Capacite loop
         for i in 1..Capacite loop
            G(i)(j):=0.0;
         end loop;
         New_Line;
      end loop;
   end Initialiser_G;


   procedure Construire_G( G: in out T_Matrice; alpha: Float; adresse: Unbounded_String) is

      File : Ada.Text_IO.File_Type;
      Nombre_Pages, Numero_Page_Pointee, ecart: Integer;
      Numero_Page: Integer;
      Numero_Page_Old: Integer;
      Nombre_Fleche_Page : Integer := 0;

      tmp: Integer;
      ordre: Integer;

   begin

      open(File, In_File,To_String(adresse));
      Get(File, Nombre_Pages);

      Get(File,Numero_Page);
      Get(File,Numero_Page_Pointee);

      if Numero_Page > Numero_Page_Pointee then
         ordre := 0;
         tmp := Numero_Page;
         Numero_Page := Numero_Page_Pointee;
         Numero_Page_Pointee := tmp;
      else
         ordre := 1;
      end if;

      G(Numero_Page_Pointee+1)(Numero_Page+1) := 1.0;

      while not end_of_file(File) loop

         Nombre_Fleche_Page := Nombre_Fleche_Page+1;
         Numero_Page_Old := Numero_Page;
         Recuperer_Bon_Ordre(Numero_Page,Numero_Page_Pointee, ordre, File);


         G(Numero_Page_Pointee+1)(Numero_Page+1):=1.0;

         ecart := Numero_Page - Numero_Page_Old;

         if ecart > 1 then
            for i in 1..Nombre_Pages loop
               G(i)(Numero_Page_Old+1):=(G(i)(Numero_Page_Old+1)/Float(Nombre_Fleche_Page))*alpha+(1.0-alpha)/Float(Nombre_Pages);
            end loop;
            for j in 2..ecart loop
               for i in 1..Nombre_Pages loop
                  G(i)(Numero_Page_Old+j):=(1.0/Float(Nombre_Pages))*alpha+(1.0-alpha)/Float(Nombre_Pages);
               end loop;
            end loop;
         elsif ecart =1 then
            for i in 1..Nombre_Pages loop
               G(i)(Numero_Page_Old+1) := (G(i)(Numero_Page_Old+1)/Float(Nombre_Fleche_Page))*alpha+(1.0-alpha)/Float(Nombre_Pages);
            end loop;
         end if;

         if ecart /=0 then
            Nombre_Fleche_Page := 0;
         end if;
      end loop;

      -- On gere le dernier tour de boucle !

      for i in 1..Nombre_Pages loop
         if G(i)(Nombre_Pages)/=0.0 then
            Nombre_Fleche_Page:=Nombre_Fleche_Page+1;
         end if;
      end loop;

      for i in 1..Nombre_Pages loop
         G(i)(Numero_Page+1) := (G(i)(Numero_Page+1)/Float(Nombre_Fleche_Page))*alpha+(1.0-alpha)/Float(Nombre_Pages);
      end loop;
      Close(File);

   end Construire_G;



   procedure Recuperer_Bon_Ordre(Numero_Page, Numero_Page_Pointee: out Integer ; ordre: in Integer; File: in Ada.Text_IO.File_Type ) is
   begin

      if ordre=1 then
         Get(File,Numero_Page);
         Get(File,Numero_Page_Pointee);
      else
         Get(File,Numero_Page_Pointee);
         Get(File,Numero_Page);
      end if;

   end Recuperer_Bon_Ordre;


   procedure Afficher( G: in T_Matrice) is
   begin

      for j in 1..Capacite loop
         for i in 1..Capacite loop
            Put(G(i)(j), 4);
         end loop;
         New_Line;
      end loop;

   end Afficher;

   procedure Afficher( Vecteur_Poids: in T_Vecteur) is
   begin
      for i in 1..Capacite loop
         Put(Vecteur_Poids(i));
      end loop;
      New_Line;
   end Afficher;


   procedure Calculer_Vecteur_Poids(Vecteur_Poids: in out T_Vecteur; Iterations: in Integer ; G: in T_Matrice; Nombre_Pages : in Integer) is
      V_poids_tmp: T_Vecteur;
   begin
      Initialiser_Vecteur_Poids(V_poids_tmp);
      for i in 1..Iterations loop
         for Colonne in 1..Nombre_Pages loop
            V_poids_tmp(Colonne):=0.0;
            for Ligne in 1..Nombre_Pages loop
               V_poids_tmp(Colonne) := V_poids_tmp(Colonne)+Vecteur_Poids(ligne)*(G(Colonne)(Ligne));
            end loop;
         end loop;
         Vecteur_Poids:=V_poids_tmp;
      end loop;
   end Calculer_Vecteur_Poids;




   function Taille(Vecteur_Poids: in T_Vecteur) return Integer is
      Taille: Integer:=0;
   begin
      return Vecteur_Poids'Length;
   end Taille;


   procedure Conversion_Type(Vecteur_Poids: in T_Vecteur; Vecteur_Poids_pour_tri: out T_Vecteur_Pour_Tri) is
   begin
      for i in 1..Capacite loop
         Vecteur_Poids_pour_tri(i):=Vecteur_Poids(i);
      end loop;
   end Conversion_Type;




   --On va mettre en place un Quicksort qui conserve l'indice inital :)

   procedure Tri_Poids (Vecteur_Poids_pour_tri: in out T_Vecteur_Pour_Tri; Indices:in out T_Indices) is

      procedure Echanger(Gauche, Droite : Integer) is
         TempVal : Float := Vecteur_Poids_pour_tri (Gauche);
         TempInd : Integer := Indices (Gauche);
      begin
         Vecteur_Poids_pour_tri (Gauche) := Vecteur_Poids_pour_tri (Droite);
         Vecteur_Poids_pour_tri (Droite) := TempVal;
         Indices(Gauche) := Indices(Droite);
         Indices(Droite) := TempInd;
      end Echanger;

   begin
      if Vecteur_Poids_pour_tri'Length> 1 then
         declare
            Pivot_Valeur :  Float := Vecteur_Poids_pour_tri (Vecteur_Poids_pour_tri'First);
            Droite       : Integer := Vecteur_Poids_pour_tri'Last;
            Gauche       : Integer := Vecteur_Poids_pour_tri'First;
         begin
            loop
               while Gauche < Droite and not (Pivot_Valeur < Vecteur_Poids_pour_tri (Gauche)) loop
                  Gauche :=Gauche+1;
               end loop;

               while Pivot_Valeur < Vecteur_Poids_pour_tri (Droite) loop
                  Droite := Droite-1;
               end loop;

               exit when Droite <= Gauche;

               Echanger (Gauche, Droite);
               Gauche := Gauche+1;
               Droite := Droite-1;
            end loop;

            if Droite = Vecteur_Poids_pour_tri'Last then
               Droite :=Droite-1;
               Echanger (Vecteur_Poids_pour_tri'First, Vecteur_Poids_pour_tri'Last);
            end if;

            if Gauche = Vecteur_Poids_pour_tri'First then
               Gauche := Gauche+1;
            end if;

            Tri_Poids (Vecteur_Poids_pour_tri (Vecteur_Poids_pour_tri'First .. Droite), Indices);
            Tri_Poids (Vecteur_Poids_pour_tri (Gauche .. Vecteur_Poids_pour_tri'Last), Indices);

         end;
      end if;
   end Tri_Poids;

   procedure Ecriture_Fichiers(Vecteur_Poids_pour_tri:in T_Vecteur_Pour_Tri; Indices: in T_Indices; adresse: in Unbounded_String; alpha: in Float; Iterations: In Integer) is
      File : Ada.Text_IO.File_Type;
      adresseP : Unbounded_String;
      adresseO : Unbounded_String;
   begin
      adresseP := Replace_Slice(adresse,Length(adresse)-3,Length(adresse),".p");

      Create(File, Out_File, To_String(adresseP));

      Put(File, Capacite, 1);
      Put(File, alpha, 2);
      Put(File, Iterations,4);
      New_Line(File);

      for i in 0..(Vecteur_Poids_pour_tri'Length-1) loop
         put(File, Vecteur_Poids_pour_tri(Vecteur_Poids_pour_tri'Length-i));
         New_Line(File);
      end loop;
      Close(File);

      adresseO := Replace_Slice(adresse,Length(adresse)-3,Length(adresse),".ord");

      Create(File, Out_File, To_String(adresseO));

      for i in 0..(Indices'Length-1) loop
         put(File, (Indices(Vecteur_Poids_pour_tri'Length-i)-1),1);
         New_Line(File);
      end loop;
      Close(File);

   end Ecriture_Fichiers;
end g_naive;
