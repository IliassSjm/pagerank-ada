with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Command_line; use Ada.Command_line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with g_naive;
with g_creuse;
with Ada.Unchecked_Deallocation;
procedure pagerank is


   File : Ada.Text_IO.File_Type;
   Nombre_pages: Integer;
   alpha: Float;
   Iterations: Integer;
   adresse: Unbounded_String;

   exception_ligne_de_commande : Exception;

begin

   --on normalise les arguments



   if Argument_Count = 1 then
      --on lance google_creuse
      alpha := 0.85;
      Iterations := 150;

   elsif Argument_Count = 2 and (Argument(1) in "-P"|"-p") then
      --on lance google_naive
      alpha := 0.85;
      Iterations := 150;

   elsif Argument_Count = 3 then
      -- on lance google_creuse
      if Argument(1) in "-I"|"-i" then
         Iterations:= Integer'Value(Argument(2));
         alpha := 0.85;
      elsif Argument(1) in "-A"|"-a" then
         alpha:= Float'Value(Argument(2));
         Iterations := 150;
      else
         raise exception_ligne_de_commande;
      end if;

   elsif Argument_Count = 4 then
      -- on lance google_naive
      if Argument(1) in "-I"|"-i" then
         Iterations:= Integer'Value(Argument(2));
         alpha := 0.85;
      elsif Argument(1) in "-A"|"-a" then
         alpha:= Float'Value(Argument(2));
         Iterations := 150;
      elsif Argument(1) in "-P"|"-p" then
         if Argument(2) in "-I"|"-i" then
            Iterations:= Integer'Value(Argument(3));
            alpha := 0.85;
         elsif Argument(2) in "-A"|"-a" then
            alpha:= Float'Value(Argument(3));
            Iterations := 150;
         else
            raise exception_ligne_de_commande;
         end if;
      else
         raise exception_ligne_de_commande;
      end if;

   elsif Argument_Count = 5 then
      --on lance google_creuse
      if Argument(1) in "-I"|"-i" then
         Iterations:= Integer'Value(Argument(2));
         alpha:= Float'Value(Argument(4));
      elsif Argument(1) in "-A"|"-a" then
         alpha:= Float'Value(Argument(2));
         Iterations:= Integer'Value(Argument(4));
      else
         raise exception_ligne_de_commande;
      end if;

   elsif Argument_Count = 6 then
      --on lance google_naive
      if Argument(1) in "-I"|"-i" then
         Iterations:= Integer'Value(Argument(2));
         if Argument(3) in "-A"|"-a" then
            alpha:= Float'Value(Argument(4));
         elsif Argument(3) in "-P"|"-p" then
            alpha:= Float'Value(Argument(5));
         else
            raise exception_ligne_de_commande;
         end if;
      elsif Argument(1) in "-A"|"-a" then
         alpha:= Float'Value(Argument(2));
         if Argument(3) in "-I"|"-i" then
            Iterations:= Integer'Value(Argument(4));
         elsif Argument(3) in "-P"|"-p" then
            Iterations:= Integer'Value(Argument(5));
         else
            raise exception_ligne_de_commande;
         end if;
      elsif Argument(1) in "-P"|"-p" then
         if Argument(2) in "-I"|"-i" then
            Iterations:= Integer'Value(Argument(3));
            alpha:= Float'Value(Argument(5));
         elsif Argument(2) in "-A"|"-a" then
            alpha:= Float'Value(Argument(3));
            Iterations:= Integer'Value(Argument(5));
         else
            raise exception_ligne_de_commande;
         end if;
      else
         raise exception_ligne_de_commande;
      end if;

   else
      raise exception_ligne_de_commande;
   end if;

   adresse:= To_Unbounded_String(Argument(Argument_Count));  -- le dernier argument est forcément le fichier

   open(File, In_File,To_String(adresse));
   Get(File, Nombre_Pages);
   Close(File);

   if Argument_Count mod 2 = 0 then

      declare


         package g_naive6 is new G_naive(Capacite=> Nombre_Pages);
         use g_naive6;
         --procedure Tri_poids3/6/9 is new Tri_Poids(Element);


         G : T_Matrice;
         Vecteur_Poids: T_Vecteur;
         Indices: T_Indices;
         Vecteur_Poids_pour_tri: T_Vecteur_Pour_Tri(1..Nombre_pages);
      begin

         Initialiser_G(G);
         Construire_G(G, alpha, adresse);
         New_Line;

         --Afficher(G);
         New_Line;

         Initialiser_Vecteur_Poids(Vecteur_Poids);
         --Afficher(Vecteur_Poids);
         New_Line;

         Calculer_Vecteur_Poids(Vecteur_Poids, Iterations, G, Nombre_Pages);
         --Afficher(Vecteur_Poids);
         Initialiser_Indices(Indices);
         Conversion_Type(Vecteur_Poids, Vecteur_Poids_pour_tri);
         Tri_Poids(Vecteur_Poids_pour_tri, Indices);
         Ecriture_Fichiers(Vecteur_Poids_pour_tri, Indices, adresse, alpha, Iterations);

      end;

   elsif Argument_Count mod 2 /= 0 then
      declare
         package g_creuse6 is new g_creuse(Capacite=> Nombre_Pages);
         use g_creuse6;

         A, IA, JA : T_Creuse;
         G : T_Matrice;
         Vecteur_Poids: T_Vecteur;
         Indices: T_Indices;
         Vecteur_Poids_pour_tri: T_Vecteur_Pour_Tri(1..Nombre_pages);

      begin
         Initialiser_G(G);
         Construire_A_IA_JA(A, IA, JA, adresse);
         Construire_G(G, alpha, A, IA, JA, adresse);
         Vider(A);
         Vider(IA);
         Vider(JA);
         New_Line;
         Initialiser_Vecteur_Poids(Vecteur_Poids);
         New_Line;
         Calculer_Vecteur_Poids(Vecteur_Poids, Iterations, G, Nombre_Pages);
         Initialiser_Indices(Indices);
         Conversion_Type(Vecteur_Poids, Vecteur_Poids_pour_tri);
         Tri_Poids(Vecteur_Poids_pour_tri, Indices);
         Ecriture_Fichiers(Vecteur_Poids_pour_tri, Indices, adresse, alpha, Iterations);
      end;
   end if;

exception
   when exception_ligne_de_commande => put("Attention la ligne de commande est incorrecte... essayez comme ca : './pagerank -P -I 150 -A 0.90 exemple_sujet.net'");
end;
