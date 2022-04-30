# Вычисляет оптимальное положение на экране для заданного прямоугольника, позволяющее ему оставаться полностью в пределах экрана
# Если задан второй параметр, будет также учитываться зона на экране, которую не будет задевать прямоугольник
# Если на экране нет места чтобы не было пересечения с "мертвой зоной", то она игнорируется
# Оба параметра задаются в глобальных координатах экрана. Результат - новая позиция для прямоугольника
func match_screen(initial_rect: Rect2, dead_zone: = Rect2()) -> Vector2:
	var screen = get_viewport().get_visible_rect()
	var result = _match_rectangle(initial_rect, screen)
	
	if result.intersects(dead_zone):	# если исходный прямоугольник пересекает "мертвую зону"
		# определение четырех зон, в пределах которых нет пересечения с "мертвой зоной"
		var zones = [Rect2(0, 0, screen.size.x, dead_zone.position.y) \
				, Rect2(dead_zone.end.x, 0, screen.end.x - dead_zone.end.x, screen.size.y) \
				, Rect2(0, dead_zone.end.y, screen.size.x, screen.end.y - dead_zone. end.y) \
				, Rect2(0, 0, dead_zone.position.x, screen.size.y)]
		var results = []	# список всех подходящих вариантов расположения
		var best_result: Rect2	# лучший вариант расположения (ближайший к исходному прямоугольнику)
		for zone in zones:
			var res = _match_rectangle(initial_rect, zone)	# находим положение для каждой зоны
			# если найденное положение находится в пределах экрана и не пересекается с "мертвой зоной"
			if screen.encloses(res.grow(-1)) and !res.intersects(dead_zone):
				results.append(res)
				best_result = res
		for res in results:
			# находим наименьшее расстояние до исходного прямоугольника
			if (res.position - initial_rect.position).length() < (best_result.position - initial_rect.position).length():
				best_result = res
		if best_result:
			result = best_result
			
	return result.position

# Вспомогательная функция для match_screen_dimensions. Корректирует позицию первого прямоугольника, вписывая его во второй прямоугольник
func _match_rectangle(what: Rect2, where: Rect2) -> Rect2:
	where.size -= what.size
	var x = clamp(what.position.x, where.position.x, where.end.x)
	var y = clamp(what.position.y, where.position.y, where.end.y)
	what.position = Vector2(x, y)
	return what
