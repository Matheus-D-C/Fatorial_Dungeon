extends Node

var timer_ativo: bool = false

var cena_game_over: String = "res://cenas/GameOver.tscn"
var cena_vitoria: String = "res://cenas/TelaFinal.tscn"


var perguntas_personalizadas = {
	1: "De quantas maneiras diferentes 3 pessoas podem sentar em uma fila?",
	2: "Quantos anagramas podemos formar com a palavras 'CASA'?",
	3: "Calcule o valor de P5 (Permutação simples de 5 elementos).",
	4: "Quantos anagramas da palavra 'LIVRO' começam com a letra L?"
}

var respostas_personalizadas = {
	1: "6",    
	2: "12",   
	3: "120",  
	4: "24"    
}
