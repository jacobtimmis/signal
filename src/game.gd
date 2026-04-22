class_name Game
extends Node2D

static var instance: Game

@onready var score_manager: ScoreManager = %ScoreManager
@onready var hero: Hero = %Hero
@onready var hud: Control = %HUD
@onready var end_screen: EndScreen = %EndScreen
@onready var decal_layer: Node2D = %DecalLayer
@onready var prop_layer: Node2D = %PropLayer
@onready var entity_layer: Node2D = %EntityLayer
@onready var projectile_layer: Node2D = %ProjectileLayer
@onready var hero_layer: Node2D = %HeroLayer


static func get_decal_layer() -> Node2D:
    return instance.decal_layer


static func get_prop_layer() -> Node2D:
    return instance.prop_layer


static func get_entity_layer() -> Node2D:
    return instance.entity_layer


static func get_projectile_layer() -> Node2D:
    return instance.projectile_layer


static func get_hero() -> Hero:
    return instance.hero


func _init() -> void:
    instance = self


func _on_hero_defeated() -> void:
    hud.hide()
    end_screen.update_and_show(score_manager.score, hero.survive_time)
