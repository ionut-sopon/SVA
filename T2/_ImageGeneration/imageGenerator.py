import cv2
import numpy as np
import random

# Image size
width, height = 800, 600
background_color = (255, 255, 255)  # White background

# Colors
colors = {
    'red': (0, 0, 255),
    'green': (0, 255, 0),
    'blue': (255, 0, 0),
    'yellow': (0, 255, 255),
    'magenta': (255, 0, 255),
    'cyan': (255, 255, 0),
    'orange': (0, 165, 255),
    'purple': (128, 0, 128),
}

# --- Utility Functions ---
def boxes_overlap(box1, box2):
    return not (
        box1[2] < box2[0] or
        box1[0] > box2[2] or
        box1[3] < box2[1] or
        box1[1] > box2[3]
    )

def is_valid_position(new_box, existing_boxes):
    for box in existing_boxes:
        if boxes_overlap(new_box, box):
            return False
    return True

# --- Drawing Functions ---
def draw_random_rectangle(img, existing_boxes):
    for _ in range(50):
        x1 = random.randint(0, width - 200)
        y1 = random.randint(0, height - 200)
        x2 = x1 + random.randint(100, 200)
        y2 = y1 + random.randint(100, 200)
        box = (x1, y1, x2, y2)
        if is_valid_position(box, existing_boxes):
            color = random.choice(list(colors.values()))
            cv2.rectangle(img, (x1, y1), (x2, y2), color, -1)
            existing_boxes.append(box)
            break

def draw_random_circle(img, existing_boxes):
    for _ in range(50):
        radius = random.randint(50, 100)
        x = random.randint(radius, width - radius)
        y = random.randint(radius, height - radius)
        box = (x - radius, y - radius, x + radius, y + radius)
        if is_valid_position(box, existing_boxes):
            color = random.choice(list(colors.values()))
            cv2.circle(img, (x, y), radius, color, -1)
            existing_boxes.append(box)
            break

def draw_random_triangle(img, existing_boxes):
    for _ in range(50):
        x = random.randint(100, width - 100)
        y = random.randint(100, height - 100)
        size = random.randint(100, 150)
        pt1 = (x, y)
        pt2 = (x - size // 2, y + size)
        pt3 = (x + size // 2, y + size)
        box = (min(pt1[0], pt2[0], pt3[0]), min(pt1[1], pt2[1], pt3[1]),
               max(pt1[0], pt2[0], pt3[0]), max(pt1[1], pt2[1], pt3[1]))
        if is_valid_position(box, existing_boxes):
            pts = np.array([pt1, pt2, pt3], np.int32).reshape((-1, 1, 2))
            color = random.choice(list(colors.values()))
            cv2.fillPoly(img, [pts], color)
            existing_boxes.append(box)
            break

def draw_random_polygon(img, existing_boxes, sides=6):
    for _ in range(50):
        radius = random.randint(80, 120)
        cx = random.randint(radius + 10, width - radius - 10)
        cy = random.randint(radius + 10, height - radius - 10)
        box = (cx - radius, cy - radius, cx + radius, cy + radius)
        if is_valid_position(box, existing_boxes):
            angle = 2 * np.pi / sides
            points = [
                (
                    int(cx + radius * np.cos(i * angle)),
                    int(cy + radius * np.sin(i * angle))
                ) for i in range(sides)
            ]
            pts = np.array(points, np.int32).reshape((-1, 1, 2))
            color = random.choice(list(colors.values()))
            cv2.fillPoly(img, [pts], color)
            existing_boxes.append(box)
            break

def draw_triangle_with_circle(img, existing_boxes):
    for _ in range(50):
        x = random.randint(150, width - 150)
        y = random.randint(150, height - 150)
        size = random.randint(120, 180)
        pt1 = (x, y)
        pt2 = (x - size // 2, y + size)
        pt3 = (x + size // 2, y + size)
        box = (x - size // 2, y, x + size // 2, y + size)
        if is_valid_position(box, existing_boxes):
            triangle_pts = np.array([pt1, pt2, pt3], np.int32).reshape((-1, 1, 2))
            triangle_color = random.choice(list(colors.values()))
            cv2.fillPoly(img, [triangle_pts], triangle_color)
            
            circle_center = (x, y + size // 2)
            circle_radius = size // 4
            circle_color = (200, 200, 200)
            cv2.circle(img, circle_center, circle_radius, circle_color, -1)
            existing_boxes.append(box)
            break

def draw_square_with_diamond(img, existing_boxes):
    for _ in range(50):
        x = random.randint(150, width - 300)
        y = random.randint(150, height - 300)
        size = random.randint(150, 200)
        box = (x, y, x + size, y + size)
        if is_valid_position(box, existing_boxes):
            top_left = (x, y)
            bottom_right = (x + size, y + size)
            square_color = (0, 255, 255)
            cv2.rectangle(img, top_left, bottom_right, square_color, -1)
            
            cx = x + size // 2
            cy = y + size // 2
            half = size // 2 - 10
            diamond_pts = np.array([
                (cx, cy - half),
                (cx + half, cy),
                (cx, cy + half),
                (cx - half, cy)
            ], np.int32).reshape((-1, 1, 2))
            diamond_color = (128, 128, 200)
            cv2.fillPoly(img, [diamond_pts], diamond_color)
            existing_boxes.append(box)
            break

# --- Image Generation Loop ---
for i in range(3):
    img = np.zeros((height, width, 3), dtype=np.uint8)
    img[:] = background_color
    existing_boxes = []

    for _ in range(2):
        draw_random_rectangle(img, existing_boxes)
        draw_random_circle(img, existing_boxes)
        draw_random_triangle(img, existing_boxes)
        draw_random_polygon(img, existing_boxes, sides=6)
        draw_triangle_with_circle(img, existing_boxes)
        draw_square_with_diamond(img, existing_boxes)

    filename = f"geometric_figures_{i+1}.png"
    cv2.imwrite(filename, img)
    print(f"Image saved as {filename}")