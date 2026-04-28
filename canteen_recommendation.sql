/*
 Navicat Premium Dump SQL

 Source Server         : demo
 Source Server Type    : MySQL
 Source Server Version : 80037 (8.0.37)
 Source Host           : localhost:3306
 Source Schema         : canteen_recommendation

 Target Server Type    : MySQL
 Target Server Version : 80037 (8.0.37)
 File Encoding         : 65001

 Date: 23/03/2026 12:09:54
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for canteens
-- ----------------------------
DROP TABLE IF EXISTS `canteens`;
CREATE TABLE `canteens`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `floor_count` int NULL DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `update_time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `UKk84ajrcxvkybrim5ap5j3vyhf`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of canteens
-- ----------------------------
INSERT INTO `canteens` VALUES (1, NULL, '提供各类中餐和西餐', 3, '校园南区', '第一食堂', '2026-02-21 20:30:59.815698');
INSERT INTO `canteens` VALUES (2, NULL, '特色菜品丰富，环境舒适', 3, '校园北区', '第二食堂', '2026-02-21 20:31:17.684158');
INSERT INTO `canteens` VALUES (3, NULL, '新装修食堂，设施齐全', 3, '校园西区', '第三食堂', '2026-02-21 20:31:21.092970');

-- ----------------------------
-- Table structure for cart_items
-- ----------------------------
DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE `cart_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `price` decimal(38, 2) NOT NULL,
  `quantity` int NOT NULL,
  `update_time` datetime(6) NULL DEFAULT NULL,
  `dish_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `is_gift` bit(1) NULL DEFAULT NULL,
  `combo_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKqf96jt4hthdxw36s3ebnq1yns`(`dish_id` ASC) USING BTREE,
  INDEX `FK709eickf3kc0dujx3ub9i7btf`(`user_id` ASC) USING BTREE,
  INDEX `FKehppwg68060786o4y7l1hl109`(`combo_id` ASC) USING BTREE,
  CONSTRAINT `FK709eickf3kc0dujx3ub9i7btf` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKehppwg68060786o4y7l1hl109` FOREIGN KEY (`combo_id`) REFERENCES `combos` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKqf96jt4hthdxw36s3ebnq1yns` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 132 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cart_items
-- ----------------------------

-- ----------------------------
-- Table structure for categories
-- ----------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `level` int NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `status` bit(1) NULL DEFAULT NULL,
  `update_time` datetime(6) NULL DEFAULT NULL,
  `parent_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKsaok720gsu4u2wrgbk10b5n8d`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `FKsaok720gsu4u2wrgbk10b5n8d` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of categories
-- ----------------------------
INSERT INTO `categories` VALUES (1, NULL, '麻辣鲜香，口味浓郁', NULL, NULL, '川菜', NULL, NULL, NULL);
INSERT INTO `categories` VALUES (2, NULL, '清淡鲜美，讲究原汁原味', NULL, NULL, '粤菜', NULL, NULL, NULL);
INSERT INTO `categories` VALUES (3, NULL, '咸鲜为主，讲究火候', NULL, NULL, '鲁菜', NULL, NULL, NULL);
INSERT INTO `categories` VALUES (4, NULL, '清淡雅致，注重造型', NULL, NULL, '苏菜', NULL, NULL, NULL);
INSERT INTO `categories` VALUES (5, NULL, '香辣可口，下饭神器', NULL, NULL, '湘菜', NULL, NULL, NULL);
INSERT INTO `categories` VALUES (6, NULL, '鲜美清淡，注重食材本味', NULL, NULL, '浙菜', NULL, NULL, NULL);
INSERT INTO `categories` VALUES (7, NULL, '家常口味，营养均衡', NULL, NULL, '家常菜', NULL, NULL, NULL);
INSERT INTO `categories` VALUES (8, NULL, '地方特色，风味独特', NULL, NULL, '特色小吃', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for combo_dishes
-- ----------------------------
DROP TABLE IF EXISTS `combo_dishes`;
CREATE TABLE `combo_dishes`  (
  `combo_id` bigint NOT NULL,
  `dish_id` bigint NOT NULL,
  INDEX `FK93v799hmrxmwxruicqb3ew8ox`(`dish_id` ASC) USING BTREE,
  INDEX `FKpguiexhqixrynuygvcvan66up`(`combo_id` ASC) USING BTREE,
  CONSTRAINT `FK93v799hmrxmwxruicqb3ew8ox` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKpguiexhqixrynuygvcvan66up` FOREIGN KEY (`combo_id`) REFERENCES `combos` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of combo_dishes
-- ----------------------------
INSERT INTO `combo_dishes` VALUES (8, 3);
INSERT INTO `combo_dishes` VALUES (8, 5);
INSERT INTO `combo_dishes` VALUES (8, 14);

-- ----------------------------
-- Table structure for combos
-- ----------------------------
DROP TABLE IF EXISTS `combos`;
CREATE TABLE `combos`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `original_price` double NOT NULL,
  `price` double NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `promotion_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK8mwig1awme8u3bgl825v48eqc`(`promotion_id` ASC) USING BTREE,
  CONSTRAINT `FK8mwig1awme8u3bgl825v48eqc` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of combos
-- ----------------------------
INSERT INTO `combos` VALUES (8, '', '单人套餐', 50, 20, 'active', 13);

-- ----------------------------
-- Table structure for daily_dish_statistics
-- ----------------------------
DROP TABLE IF EXISTS `daily_dish_statistics`;
CREATE TABLE `daily_dish_statistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `alert_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `alert_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `daily_limit` int NULL DEFAULT NULL,
  `statistic_date` date NOT NULL,
  `dish_id` bigint NOT NULL,
  `dish_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `end_stock` int NULL DEFAULT NULL,
  `sales` int NULL DEFAULT NULL,
  `total_supply` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 342 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of daily_dish_statistics
-- ----------------------------
INSERT INTO `daily_dish_statistics` VALUES (1, 'NORMAL', NULL, '2026-02-09 12:05:43.116330', 0, '2026-02-08', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (2, 'NORMAL', NULL, '2026-02-09 12:05:43.167545', 100, '2026-02-08', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (3, 'NORMAL', NULL, '2026-02-09 12:05:43.169350', 100, '2026-02-08', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (4, 'NORMAL', NULL, '2026-02-09 12:05:43.172122', 100, '2026-02-08', 4, '西红柿鸡蛋', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (5, 'NORMAL', NULL, '2026-02-09 12:05:43.174992', 100, '2026-02-08', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (6, 'NORMAL', NULL, '2026-02-09 12:05:43.177217', 100, '2026-02-08', 6, '紫菜蛋花汤', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (7, 'CRITICAL', '库存极低（剩余 9 份），请立即补货', '2026-02-09 12:05:43.179289', 59, '2026-02-08', 7, '鱼香肉丝', 9, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (8, 'NORMAL', NULL, '2026-02-09 12:05:43.182119', 73, '2026-02-08', 8, '清蒸鱼', 70, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (9, 'NORMAL', NULL, '2026-02-09 12:05:43.184253', 111, '2026-02-08', 9, '清真牛肉饭', 111, 1, 111);
INSERT INTO `daily_dish_statistics` VALUES (10, 'NORMAL', NULL, '2026-02-09 12:05:43.186009', 185, '2026-02-08', 10, '包子', 184, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (11, 'NORMAL', NULL, '2026-02-09 12:05:43.188917', 149, '2026-02-08', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (12, 'NORMAL', NULL, '2026-02-09 12:05:43.190609', 163, '2026-02-08', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (13, 'NORMAL', NULL, '2026-02-09 12:05:43.192054', 186, '2026-02-08', 13, '白切鸡', 183, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (14, 'NORMAL', NULL, '2026-02-09 12:05:43.194887', 188, '2026-02-08', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (15, 'NORMAL', NULL, '2026-02-09 12:05:43.197126', 199, '2026-02-08', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (16, 'NORMAL', NULL, '2026-02-09 12:05:43.199913', 174, '2026-02-08', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (17, 'NORMAL', NULL, '2026-02-09 12:05:43.202164', 69, '2026-02-08', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (18, 'NORMAL', NULL, '2026-02-09 12:05:43.204821', 63, '2026-02-08', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (19, 'NORMAL', NULL, '2026-02-09 12:05:43.206674', 108, '2026-02-08', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (20, 'NORMAL', NULL, '2026-02-09 12:05:43.209976', 161, '2026-02-08', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (21, 'NORMAL', NULL, '2026-02-09 12:05:43.212829', 65, '2026-02-08', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (22, 'NORMAL', NULL, '2026-02-09 12:05:43.215278', 159, '2026-02-08', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (23, 'CRITICAL', '库存极低（剩余 7 份），请立即补货', '2026-02-09 12:05:43.218869', 57, '2026-02-08', 25, '清炒虾仁', 7, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (24, 'NORMAL', NULL, '2026-02-09 12:05:43.221735', 187, '2026-02-08', 26, '扬州炒饭', 186, 0, 187);
INSERT INTO `daily_dish_statistics` VALUES (25, 'NORMAL', NULL, '2026-02-09 12:05:43.224463', 133, '2026-02-08', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (26, 'NORMAL', NULL, '2026-02-09 12:05:43.227197', 127, '2026-02-08', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (27, 'NORMAL', NULL, '2026-02-09 12:05:43.229989', 92, '2026-02-08', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (28, 'NORMAL', NULL, '2026-02-09 12:05:43.232034', 166, '2026-02-08', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (29, 'NORMAL', NULL, '2026-02-09 12:05:43.234291', 148, '2026-02-08', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (30, 'NORMAL', NULL, '2026-02-09 12:05:43.238317', 116, '2026-02-08', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (31, 'NORMAL', NULL, '2026-02-09 12:05:43.239843', 119, '2026-02-08', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (32, 'NORMAL', NULL, '2026-02-10 15:22:18.614786', 0, '2026-02-09', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (33, 'NORMAL', NULL, '2026-02-10 15:22:18.651048', 100, '2026-02-09', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (34, 'NORMAL', NULL, '2026-02-10 15:22:18.654689', 100, '2026-02-09', 3, '麻婆豆腐', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (35, 'NORMAL', NULL, '2026-02-10 15:22:18.657222', 100, '2026-02-09', 4, '西红柿鸡蛋', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (36, 'NORMAL', NULL, '2026-02-10 15:22:18.658771', 100, '2026-02-09', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (37, 'NORMAL', NULL, '2026-02-10 15:22:18.661482', 100, '2026-02-09', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (38, 'NORMAL', NULL, '2026-02-10 15:22:18.664533', 59, '2026-02-09', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (39, 'NORMAL', NULL, '2026-02-10 15:22:18.667253', 73, '2026-02-09', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (40, 'NORMAL', NULL, '2026-02-10 15:22:18.668793', 0, '2026-02-09', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (41, 'NORMAL', NULL, '2026-02-10 15:22:18.670357', 185, '2026-02-09', 10, '包子', 184, 1, 185);
INSERT INTO `daily_dish_statistics` VALUES (42, 'NORMAL', NULL, '2026-02-10 15:22:18.671913', 149, '2026-02-09', 11, '油条', 148, 1, 149);
INSERT INTO `daily_dish_statistics` VALUES (43, 'NORMAL', NULL, '2026-02-10 15:22:18.674619', 163, '2026-02-09', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (44, 'NORMAL', NULL, '2026-02-10 15:22:18.676631', 186, '2026-02-09', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (45, 'NORMAL', NULL, '2026-02-10 15:22:18.678142', 188, '2026-02-09', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (46, 'NORMAL', NULL, '2026-02-10 15:22:18.681290', 199, '2026-02-09', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (47, 'NORMAL', NULL, '2026-02-10 15:22:18.684882', 174, '2026-02-09', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (48, 'NORMAL', NULL, '2026-02-10 15:22:18.685880', 69, '2026-02-09', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (49, 'NORMAL', NULL, '2026-02-10 15:22:18.689421', 63, '2026-02-09', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (50, 'NORMAL', NULL, '2026-02-10 15:22:18.691017', 108, '2026-02-09', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (51, 'NORMAL', NULL, '2026-02-10 15:22:18.692672', 161, '2026-02-09', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (52, 'NORMAL', NULL, '2026-02-10 15:22:18.695747', 65, '2026-02-09', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (53, 'NORMAL', NULL, '2026-02-10 15:22:18.697275', 159, '2026-02-09', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (54, 'NORMAL', NULL, '2026-02-10 15:22:18.700421', 57, '2026-02-09', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (55, 'NORMAL', NULL, '2026-02-10 15:22:18.701964', 187, '2026-02-09', 26, '扬州炒饭', 187, 0, 187);
INSERT INTO `daily_dish_statistics` VALUES (56, 'NORMAL', NULL, '2026-02-10 15:22:18.703530', 133, '2026-02-09', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (57, 'NORMAL', NULL, '2026-02-10 15:22:18.705593', 127, '2026-02-09', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (58, 'NORMAL', NULL, '2026-02-10 15:22:18.709134', 92, '2026-02-09', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (59, 'NORMAL', NULL, '2026-02-10 15:22:18.710817', 166, '2026-02-09', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (60, 'NORMAL', NULL, '2026-02-10 15:22:18.714068', 148, '2026-02-09', 31, '龙井虾仁', 147, 1, 148);
INSERT INTO `daily_dish_statistics` VALUES (61, 'NORMAL', NULL, '2026-02-10 15:22:18.715578', 116, '2026-02-09', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (62, 'NORMAL', NULL, '2026-02-10 15:22:18.717376', 119, '2026-02-09', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (63, 'NORMAL', NULL, '2026-02-11 17:14:43.100159', 0, '2026-02-10', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (64, 'NORMAL', NULL, '2026-02-11 17:14:43.101725', 100, '2026-02-10', 2, '宫保鸡丁', 96, 3, 100);
INSERT INTO `daily_dish_statistics` VALUES (65, 'NORMAL', NULL, '2026-02-11 17:14:43.104792', 100, '2026-02-10', 3, '麻婆豆腐', 96, 4, 100);
INSERT INTO `daily_dish_statistics` VALUES (66, 'NORMAL', NULL, '2026-02-11 17:14:43.106576', 100, '2026-02-10', 4, '西红柿鸡蛋', 100, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (67, 'NORMAL', NULL, '2026-02-11 17:14:43.109738', 100, '2026-02-10', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (68, 'NORMAL', NULL, '2026-02-11 17:14:43.121610', 100, '2026-02-10', 6, '紫菜蛋花汤', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (69, 'NORMAL', NULL, '2026-02-11 17:14:43.122107', 59, '2026-02-10', 7, '鱼香肉丝', 58, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (70, 'NORMAL', NULL, '2026-02-11 17:14:43.123116', 73, '2026-02-10', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (71, 'NORMAL', NULL, '2026-02-11 17:14:43.125499', 0, '2026-02-10', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (72, 'NORMAL', NULL, '2026-02-11 17:14:43.126504', 185, '2026-02-10', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (73, 'NORMAL', NULL, '2026-02-11 17:14:43.132041', 149, '2026-02-10', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (74, 'NORMAL', NULL, '2026-02-11 17:14:43.132769', 163, '2026-02-10', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (75, 'NORMAL', NULL, '2026-02-11 17:14:43.133775', 186, '2026-02-10', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (76, 'NORMAL', NULL, '2026-02-11 17:14:43.133775', 188, '2026-02-10', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (77, 'NORMAL', NULL, '2026-02-11 17:14:43.135284', 199, '2026-02-10', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (78, 'NORMAL', NULL, '2026-02-11 17:14:43.135284', 174, '2026-02-10', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (79, 'NORMAL', NULL, '2026-02-11 17:14:43.136903', 69, '2026-02-10', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (80, 'NORMAL', NULL, '2026-02-11 17:14:43.136903', 63, '2026-02-10', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (81, 'NORMAL', NULL, '2026-02-11 17:14:43.136903', 108, '2026-02-10', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (82, 'NORMAL', NULL, '2026-02-11 17:14:43.138435', 161, '2026-02-10', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (83, 'NORMAL', NULL, '2026-02-11 17:14:43.138435', 65, '2026-02-10', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (84, 'NORMAL', NULL, '2026-02-11 17:14:43.138435', 0, '2026-02-10', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (85, 'NORMAL', NULL, '2026-02-11 17:14:43.139954', 57, '2026-02-10', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (86, 'NORMAL', NULL, '2026-02-11 17:14:43.139954', 0, '2026-02-10', 26, '扬州炒饭', 187, 0, 187);
INSERT INTO `daily_dish_statistics` VALUES (87, 'NORMAL', NULL, '2026-02-11 17:14:43.141477', 133, '2026-02-10', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (88, 'NORMAL', NULL, '2026-02-11 17:14:43.141477', 127, '2026-02-10', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (89, 'NORMAL', NULL, '2026-02-11 17:14:43.141477', 92, '2026-02-10', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (90, 'NORMAL', NULL, '2026-02-11 17:14:43.143002', 166, '2026-02-10', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (91, 'NORMAL', NULL, '2026-02-11 17:14:43.143002', 148, '2026-02-10', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (92, 'NORMAL', NULL, '2026-02-11 17:14:43.143002', 116, '2026-02-10', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (93, 'NORMAL', NULL, '2026-02-11 17:14:43.144665', 119, '2026-02-10', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (94, 'NORMAL', NULL, '2026-02-12 16:13:16.478169', 0, '2026-02-11', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (95, 'NORMAL', NULL, '2026-02-12 16:13:16.479685', 100, '2026-02-11', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (96, 'NORMAL', NULL, '2026-02-12 16:13:16.481021', 100, '2026-02-11', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (97, 'NORMAL', NULL, '2026-02-12 16:13:16.482027', 100, '2026-02-11', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (98, 'NORMAL', NULL, '2026-02-12 16:13:16.482533', 100, '2026-02-11', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (99, 'NORMAL', NULL, '2026-02-12 16:13:16.484043', 100, '2026-02-11', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (100, 'NORMAL', NULL, '2026-02-12 16:13:16.485049', 59, '2026-02-11', 7, '鱼香肉丝', 58, 1, 59);
INSERT INTO `daily_dish_statistics` VALUES (101, 'NORMAL', NULL, '2026-02-12 16:13:16.485555', 73, '2026-02-11', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (102, 'NORMAL', NULL, '2026-02-12 16:13:16.487021', 0, '2026-02-11', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (103, 'NORMAL', NULL, '2026-02-12 16:13:16.487970', 185, '2026-02-11', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (104, 'NORMAL', NULL, '2026-02-12 16:13:16.489482', 149, '2026-02-11', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (105, 'NORMAL', NULL, '2026-02-12 16:13:16.489987', 163, '2026-02-11', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (106, 'NORMAL', NULL, '2026-02-12 16:13:16.491499', 186, '2026-02-11', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (107, 'NORMAL', NULL, '2026-02-12 16:13:16.493187', 188, '2026-02-11', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (108, 'NORMAL', NULL, '2026-02-12 16:13:16.494452', 199, '2026-02-11', 16, '烧腊饭', 198, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (109, 'NORMAL', NULL, '2026-02-12 16:13:16.495451', 174, '2026-02-11', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (110, 'NORMAL', NULL, '2026-02-12 16:13:16.496953', 69, '2026-02-11', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (111, 'NORMAL', NULL, '2026-02-12 16:13:16.497455', 63, '2026-02-11', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (112, 'NORMAL', NULL, '2026-02-12 16:13:16.498955', 108, '2026-02-11', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (113, 'NORMAL', NULL, '2026-02-12 16:13:16.499954', 161, '2026-02-11', 22, '西红柿鸡蛋面', 160, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (114, 'NORMAL', NULL, '2026-02-12 16:13:16.500456', 65, '2026-02-11', 23, '小笼包', 64, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (115, 'NORMAL', NULL, '2026-02-12 16:13:16.502060', 0, '2026-02-11', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (116, 'NORMAL', NULL, '2026-02-12 16:13:16.503566', 57, '2026-02-11', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (117, 'NORMAL', NULL, '2026-02-12 16:13:16.504068', 0, '2026-02-11', 26, '扬州炒饭', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (118, 'NORMAL', NULL, '2026-02-12 16:13:16.505569', 133, '2026-02-11', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (119, 'NORMAL', NULL, '2026-02-12 16:13:16.506568', 127, '2026-02-11', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (120, 'NORMAL', NULL, '2026-02-12 16:13:16.507071', 92, '2026-02-11', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (121, 'NORMAL', NULL, '2026-02-12 16:13:16.508364', 166, '2026-02-11', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (122, 'NORMAL', NULL, '2026-02-12 16:13:16.508364', 148, '2026-02-11', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (123, 'NORMAL', NULL, '2026-02-12 16:13:16.509913', 116, '2026-02-11', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (124, 'NORMAL', NULL, '2026-02-12 16:13:16.511563', 119, '2026-02-11', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (125, 'NORMAL', NULL, '2026-02-18 20:29:16.599853', 0, '2026-02-17', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (126, 'NORMAL', NULL, '2026-02-18 20:29:16.638129', 100, '2026-02-17', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (127, 'NORMAL', NULL, '2026-02-18 20:29:16.641183', 100, '2026-02-17', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (128, 'NORMAL', NULL, '2026-02-18 20:29:16.642718', 100, '2026-02-17', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (129, 'NORMAL', NULL, '2026-02-18 20:29:16.645382', 100, '2026-02-17', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (130, 'NORMAL', NULL, '2026-02-18 20:29:16.648436', 100, '2026-02-17', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (131, 'NORMAL', NULL, '2026-02-18 20:29:16.650539', 59, '2026-02-17', 7, '鱼香肉丝', 58, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (132, 'NORMAL', NULL, '2026-02-18 20:29:16.652034', 73, '2026-02-17', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (133, 'NORMAL', NULL, '2026-02-18 20:29:16.653886', 0, '2026-02-17', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (134, 'NORMAL', NULL, '2026-02-18 20:29:16.656498', 185, '2026-02-17', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (135, 'NORMAL', NULL, '2026-02-18 20:29:16.658959', 149, '2026-02-17', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (136, 'NORMAL', NULL, '2026-02-18 20:29:16.660957', 163, '2026-02-17', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (137, 'NORMAL', NULL, '2026-02-18 20:29:16.663598', 186, '2026-02-17', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (138, 'NORMAL', NULL, '2026-02-18 20:29:16.665659', 188, '2026-02-17', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (139, 'NORMAL', NULL, '2026-02-18 20:29:16.668598', 199, '2026-02-17', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (140, 'NORMAL', NULL, '2026-02-18 20:29:16.670699', 174, '2026-02-17', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (141, 'NORMAL', NULL, '2026-02-18 20:29:16.673689', 69, '2026-02-17', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (142, 'NORMAL', NULL, '2026-02-18 20:29:16.675232', 63, '2026-02-17', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (143, 'NORMAL', NULL, '2026-02-18 20:29:16.678344', 108, '2026-02-17', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (144, 'NORMAL', NULL, '2026-02-18 20:29:16.680181', 161, '2026-02-17', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (145, 'NORMAL', NULL, '2026-02-18 20:29:16.681188', 65, '2026-02-17', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (146, 'NORMAL', NULL, '2026-02-18 20:29:16.682741', 0, '2026-02-17', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (147, 'NORMAL', NULL, '2026-02-18 20:29:16.686108', 57, '2026-02-17', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (148, 'NORMAL', NULL, '2026-02-18 20:29:16.687196', 0, '2026-02-17', 26, '扬州炒饭', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (149, 'NORMAL', NULL, '2026-02-18 20:29:16.688725', 133, '2026-02-17', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (150, 'NORMAL', NULL, '2026-02-18 20:29:16.690249', 127, '2026-02-17', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (151, 'NORMAL', NULL, '2026-02-18 20:29:16.692783', 92, '2026-02-17', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (152, 'NORMAL', NULL, '2026-02-18 20:29:16.694421', 166, '2026-02-17', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (153, 'NORMAL', NULL, '2026-02-18 20:29:16.695951', 148, '2026-02-17', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (154, 'NORMAL', NULL, '2026-02-18 20:29:16.697485', 116, '2026-02-17', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (155, 'NORMAL', NULL, '2026-02-18 20:29:16.699156', 119, '2026-02-17', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (156, 'NORMAL', NULL, '2026-02-19 20:33:38.989620', 0, '2026-02-18', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (157, 'NORMAL', NULL, '2026-02-19 20:33:39.015220', 100, '2026-02-18', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (158, 'NORMAL', NULL, '2026-02-19 20:33:39.017813', 100, '2026-02-18', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (159, 'NORMAL', NULL, '2026-02-19 20:33:39.030689', 100, '2026-02-18', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (160, 'NORMAL', NULL, '2026-02-19 20:33:39.033247', 100, '2026-02-18', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (161, 'NORMAL', NULL, '2026-02-19 20:33:39.034982', 100, '2026-02-18', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (162, 'NORMAL', NULL, '2026-02-19 20:33:39.042061', 59, '2026-02-18', 7, '鱼香肉丝', 57, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (163, 'NORMAL', NULL, '2026-02-19 20:33:39.049153', 73, '2026-02-18', 8, '清蒸鱼', 72, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (164, 'NORMAL', NULL, '2026-02-19 20:33:39.050668', 0, '2026-02-18', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (165, 'NORMAL', NULL, '2026-02-19 20:33:39.052178', 185, '2026-02-18', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (166, 'NORMAL', NULL, '2026-02-19 20:33:39.054690', 149, '2026-02-18', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (167, 'NORMAL', NULL, '2026-02-19 20:33:39.057396', 163, '2026-02-18', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (168, 'NORMAL', NULL, '2026-02-19 20:33:39.057396', 186, '2026-02-18', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (169, 'NORMAL', NULL, '2026-02-19 20:33:39.061735', 188, '2026-02-18', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (170, 'NORMAL', NULL, '2026-02-19 20:33:39.064375', 199, '2026-02-18', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (171, 'NORMAL', NULL, '2026-02-19 20:33:39.065882', 174, '2026-02-18', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (172, 'NORMAL', NULL, '2026-02-19 20:33:39.066887', 69, '2026-02-18', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (173, 'NORMAL', NULL, '2026-02-19 20:33:39.068562', 63, '2026-02-18', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (174, 'NORMAL', NULL, '2026-02-19 20:33:39.071472', 108, '2026-02-18', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (175, 'NORMAL', NULL, '2026-02-19 20:33:39.072476', 161, '2026-02-18', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (176, 'NORMAL', NULL, '2026-02-19 20:33:39.077009', 65, '2026-02-18', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (177, 'NORMAL', NULL, '2026-02-19 20:33:39.080749', 0, '2026-02-18', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (178, 'NORMAL', NULL, '2026-02-19 20:33:39.082965', 57, '2026-02-18', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (179, 'NORMAL', NULL, '2026-02-19 20:33:39.086459', 0, '2026-02-18', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (180, 'NORMAL', NULL, '2026-02-19 20:33:39.087965', 133, '2026-02-18', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (181, 'NORMAL', NULL, '2026-02-19 20:33:39.089497', 127, '2026-02-18', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (182, 'NORMAL', NULL, '2026-02-19 20:33:39.091516', 92, '2026-02-18', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (183, 'NORMAL', NULL, '2026-02-19 20:33:39.093529', 166, '2026-02-18', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (184, 'NORMAL', NULL, '2026-02-19 20:33:39.095557', 148, '2026-02-18', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (185, 'NORMAL', NULL, '2026-02-19 20:33:39.097091', 116, '2026-02-18', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (186, 'NORMAL', NULL, '2026-02-19 20:33:39.101532', 119, '2026-02-18', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (187, 'NORMAL', NULL, '2026-02-21 20:10:20.703316', 0, '2026-02-20', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (188, 'NORMAL', NULL, '2026-02-21 20:10:20.725910', 100, '2026-02-20', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (189, 'NORMAL', NULL, '2026-02-21 20:10:20.727420', 100, '2026-02-20', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (190, 'NORMAL', NULL, '2026-02-21 20:10:20.728932', 100, '2026-02-20', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (191, 'NORMAL', NULL, '2026-02-21 20:10:20.730542', 100, '2026-02-20', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (192, 'NORMAL', NULL, '2026-02-21 20:10:20.732099', 100, '2026-02-20', 6, '紫菜蛋花汤', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (193, 'NORMAL', NULL, '2026-02-21 20:10:20.733643', 59, '2026-02-20', 7, '鱼香肉丝', 58, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (194, 'NORMAL', NULL, '2026-02-21 20:10:20.735227', 73, '2026-02-20', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (195, 'NORMAL', NULL, '2026-02-21 20:10:20.737819', 0, '2026-02-20', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (196, 'NORMAL', NULL, '2026-02-21 20:10:20.738735', 185, '2026-02-20', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (197, 'NORMAL', NULL, '2026-02-21 20:10:20.740098', 149, '2026-02-20', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (198, 'NORMAL', NULL, '2026-02-21 20:10:20.741116', 163, '2026-02-20', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (199, 'NORMAL', NULL, '2026-02-21 20:10:20.743237', 186, '2026-02-20', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (200, 'NORMAL', NULL, '2026-02-21 20:10:20.745241', 188, '2026-02-20', 14, '广东菜心', 187, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (201, 'NORMAL', NULL, '2026-02-21 20:10:20.746765', 199, '2026-02-20', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (202, 'NORMAL', NULL, '2026-02-21 20:10:20.747773', 174, '2026-02-20', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (203, 'NORMAL', NULL, '2026-02-21 20:10:20.749597', 69, '2026-02-20', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (204, 'NORMAL', NULL, '2026-02-21 20:10:20.751672', 63, '2026-02-20', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (205, 'NORMAL', NULL, '2026-02-21 20:10:20.753508', 108, '2026-02-20', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (206, 'NORMAL', NULL, '2026-02-21 20:10:20.755032', 161, '2026-02-20', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (207, 'NORMAL', NULL, '2026-02-21 20:10:20.757229', 65, '2026-02-20', 23, '小笼包', 64, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (208, 'NORMAL', NULL, '2026-02-21 20:10:20.758651', 0, '2026-02-20', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (209, 'NORMAL', NULL, '2026-02-21 20:10:20.760161', 57, '2026-02-20', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (210, 'NORMAL', NULL, '2026-02-21 20:10:20.761670', 0, '2026-02-20', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (211, 'NORMAL', NULL, '2026-02-21 20:10:20.763192', 133, '2026-02-20', 27, '剁椒鱼头', 132, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (212, 'NORMAL', NULL, '2026-02-21 20:10:20.764715', 127, '2026-02-20', 28, '农家小炒肉', 126, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (213, 'NORMAL', NULL, '2026-02-21 20:10:20.765220', 92, '2026-02-20', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (214, 'NORMAL', NULL, '2026-02-21 20:10:20.766743', 166, '2026-02-20', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (215, 'NORMAL', NULL, '2026-02-21 20:10:20.768253', 148, '2026-02-20', 31, '龙井虾仁', 147, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (216, 'NORMAL', NULL, '2026-02-21 20:10:20.769729', 116, '2026-02-20', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (217, 'NORMAL', NULL, '2026-02-21 20:10:20.770737', 119, '2026-02-20', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (218, 'NORMAL', NULL, '2026-03-02 11:40:41.327166', 0, '2026-03-01', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (219, 'NORMAL', NULL, '2026-03-02 11:40:41.343804', 100, '2026-03-01', 2, '宫保鸡丁', 98, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (220, 'NORMAL', NULL, '2026-03-02 11:40:41.345337', 100, '2026-03-01', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (221, 'NORMAL', NULL, '2026-03-02 11:40:41.346862', 100, '2026-03-01', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (222, 'NORMAL', NULL, '2026-03-02 11:40:41.347534', 100, '2026-03-01', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (223, 'NORMAL', NULL, '2026-03-02 11:40:41.348931', 100, '2026-03-01', 6, '紫菜蛋花汤', 98, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (224, 'NORMAL', NULL, '2026-03-02 11:40:41.352286', 59, '2026-03-01', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (225, 'NORMAL', NULL, '2026-03-02 11:40:41.354336', 73, '2026-03-01', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (226, 'NORMAL', NULL, '2026-03-02 11:40:41.356414', 0, '2026-03-01', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (227, 'NORMAL', NULL, '2026-03-02 11:40:41.357439', 185, '2026-03-01', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (228, 'NORMAL', NULL, '2026-03-02 11:40:41.357948', 149, '2026-03-01', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (229, 'NORMAL', NULL, '2026-03-02 11:40:41.360495', 163, '2026-03-01', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (230, 'NORMAL', NULL, '2026-03-02 11:40:41.368765', 186, '2026-03-01', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (231, 'NORMAL', NULL, '2026-03-02 11:40:41.371889', 188, '2026-03-01', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (232, 'NORMAL', NULL, '2026-03-02 11:40:41.373831', 199, '2026-03-01', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (233, 'NORMAL', NULL, '2026-03-02 11:40:41.376085', 174, '2026-03-01', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (234, 'NORMAL', NULL, '2026-03-02 11:40:41.377723', 69, '2026-03-01', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (235, 'NORMAL', NULL, '2026-03-02 11:40:41.379610', 63, '2026-03-01', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (236, 'NORMAL', NULL, '2026-03-02 11:40:41.382654', 108, '2026-03-01', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (237, 'NORMAL', NULL, '2026-03-02 11:40:41.384371', 161, '2026-03-01', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (238, 'NORMAL', NULL, '2026-03-02 11:40:41.385970', 65, '2026-03-01', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (239, 'NORMAL', NULL, '2026-03-02 11:40:41.389213', 0, '2026-03-01', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (240, 'NORMAL', NULL, '2026-03-02 11:40:41.389571', 57, '2026-03-01', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (241, 'NORMAL', NULL, '2026-03-02 11:40:41.391295', 0, '2026-03-01', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (242, 'NORMAL', NULL, '2026-03-02 11:40:41.396012', 133, '2026-03-01', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (243, 'NORMAL', NULL, '2026-03-02 11:40:41.397656', 127, '2026-03-01', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (244, 'NORMAL', NULL, '2026-03-02 11:40:41.399434', 92, '2026-03-01', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (245, 'NORMAL', NULL, '2026-03-02 11:40:41.404589', 166, '2026-03-01', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (246, 'NORMAL', NULL, '2026-03-02 11:40:41.411713', 148, '2026-03-01', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (247, 'NORMAL', NULL, '2026-03-02 11:40:41.412230', 116, '2026-03-01', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (248, 'NORMAL', NULL, '2026-03-02 11:40:41.415523', 119, '2026-03-01', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (249, 'NORMAL', NULL, '2026-03-05 09:58:36.941993', 0, '2026-03-04', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (250, 'NORMAL', NULL, '2026-03-05 09:58:36.972727', 100, '2026-03-04', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (251, 'NORMAL', NULL, '2026-03-05 09:58:36.975191', 100, '2026-03-04', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (252, 'NORMAL', NULL, '2026-03-05 09:58:36.978418', 100, '2026-03-04', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (253, 'NORMAL', NULL, '2026-03-05 09:58:36.980731', 100, '2026-03-04', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (254, 'NORMAL', NULL, '2026-03-05 09:58:36.982640', 100, '2026-03-04', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (255, 'NORMAL', NULL, '2026-03-05 09:58:36.985797', 59, '2026-03-04', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (256, 'NORMAL', NULL, '2026-03-05 09:58:36.987314', 73, '2026-03-04', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (257, 'NORMAL', NULL, '2026-03-05 09:58:36.989076', 0, '2026-03-04', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (258, 'NORMAL', NULL, '2026-03-05 09:58:36.991878', 185, '2026-03-04', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (259, 'NORMAL', NULL, '2026-03-05 09:58:36.993462', 149, '2026-03-04', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (260, 'NORMAL', NULL, '2026-03-05 09:58:36.995781', 163, '2026-03-04', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (261, 'NORMAL', NULL, '2026-03-05 09:58:36.997414', 186, '2026-03-04', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (262, 'NORMAL', NULL, '2026-03-05 09:58:36.999488', 188, '2026-03-04', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (263, 'NORMAL', NULL, '2026-03-05 09:58:37.002253', 199, '2026-03-04', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (264, 'NORMAL', NULL, '2026-03-05 09:58:37.005061', 174, '2026-03-04', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (265, 'NORMAL', NULL, '2026-03-05 09:58:37.006942', 69, '2026-03-04', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (266, 'NORMAL', NULL, '2026-03-05 09:58:37.009437', 63, '2026-03-04', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (267, 'NORMAL', NULL, '2026-03-05 09:58:37.011247', 108, '2026-03-04', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (268, 'NORMAL', NULL, '2026-03-05 09:58:37.013983', 161, '2026-03-04', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (269, 'NORMAL', NULL, '2026-03-05 09:58:37.016235', 65, '2026-03-04', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (270, 'NORMAL', NULL, '2026-03-05 09:58:37.018448', 0, '2026-03-04', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (271, 'NORMAL', NULL, '2026-03-05 09:58:37.019697', 57, '2026-03-04', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (272, 'NORMAL', NULL, '2026-03-05 09:58:37.023036', 0, '2026-03-04', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (273, 'NORMAL', NULL, '2026-03-05 09:58:37.024943', 133, '2026-03-04', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (274, 'NORMAL', NULL, '2026-03-05 09:58:37.025959', 127, '2026-03-04', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (275, 'NORMAL', NULL, '2026-03-05 09:58:37.027335', 92, '2026-03-04', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (276, 'NORMAL', NULL, '2026-03-05 09:58:37.030726', 166, '2026-03-04', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (277, 'NORMAL', NULL, '2026-03-05 09:58:37.032880', 148, '2026-03-04', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (278, 'NORMAL', NULL, '2026-03-05 09:58:37.035638', 116, '2026-03-04', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (279, 'NORMAL', NULL, '2026-03-05 09:58:37.038429', 119, '2026-03-04', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (280, 'NORMAL', NULL, '2026-03-11 14:46:32.464772', 0, '2026-03-10', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (281, 'NORMAL', NULL, '2026-03-11 14:46:32.505381', 100, '2026-03-10', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (282, 'NORMAL', NULL, '2026-03-11 14:46:32.508379', 100, '2026-03-10', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (283, 'NORMAL', NULL, '2026-03-11 14:46:32.509381', 100, '2026-03-10', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (284, 'NORMAL', NULL, '2026-03-11 14:46:32.510378', 100, '2026-03-10', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (285, 'NORMAL', NULL, '2026-03-11 14:46:32.511380', 100, '2026-03-10', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (286, 'NORMAL', NULL, '2026-03-11 14:46:32.512382', 59, '2026-03-10', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (287, 'NORMAL', NULL, '2026-03-11 14:46:32.513379', 73, '2026-03-10', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (288, 'NORMAL', NULL, '2026-03-11 14:46:32.514379', 0, '2026-03-10', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (289, 'NORMAL', NULL, '2026-03-11 14:46:32.515379', 185, '2026-03-10', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (290, 'NORMAL', NULL, '2026-03-11 14:46:32.515379', 149, '2026-03-10', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (291, 'NORMAL', NULL, '2026-03-11 14:46:32.516380', 163, '2026-03-10', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (292, 'NORMAL', NULL, '2026-03-11 14:46:32.517381', 186, '2026-03-10', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (293, 'NORMAL', NULL, '2026-03-11 14:46:32.518381', 188, '2026-03-10', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (294, 'NORMAL', NULL, '2026-03-11 14:46:32.519379', 199, '2026-03-10', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (295, 'NORMAL', NULL, '2026-03-11 14:46:32.520378', 174, '2026-03-10', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (296, 'NORMAL', NULL, '2026-03-11 14:46:32.521379', 69, '2026-03-10', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (297, 'NORMAL', NULL, '2026-03-11 14:46:32.522379', 63, '2026-03-10', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (298, 'NORMAL', NULL, '2026-03-11 14:46:32.523380', 108, '2026-03-10', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (299, 'NORMAL', NULL, '2026-03-11 14:46:32.524382', 161, '2026-03-10', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (300, 'NORMAL', NULL, '2026-03-11 14:46:32.525382', 65, '2026-03-10', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (301, 'NORMAL', NULL, '2026-03-11 14:46:32.527381', 0, '2026-03-10', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (302, 'NORMAL', NULL, '2026-03-11 14:46:32.529469', 57, '2026-03-10', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (303, 'NORMAL', NULL, '2026-03-11 14:46:32.530478', 0, '2026-03-10', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (304, 'NORMAL', NULL, '2026-03-11 14:46:32.531488', 133, '2026-03-10', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (305, 'NORMAL', NULL, '2026-03-11 14:46:32.532477', 127, '2026-03-10', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (306, 'NORMAL', NULL, '2026-03-11 14:46:32.534478', 92, '2026-03-10', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (307, 'NORMAL', NULL, '2026-03-11 14:46:32.535476', 166, '2026-03-10', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (308, 'NORMAL', NULL, '2026-03-11 14:46:32.536479', 148, '2026-03-10', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (309, 'NORMAL', NULL, '2026-03-11 14:46:32.537477', 116, '2026-03-10', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (310, 'NORMAL', NULL, '2026-03-11 14:46:32.538477', 119, '2026-03-10', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (311, 'NORMAL', NULL, '2026-03-12 08:31:55.336153', 119, '2026-03-11', 34, '奶茶', 118, 1, 119);
INSERT INTO `daily_dish_statistics` VALUES (312, 'NORMAL', NULL, '2026-03-12 08:31:55.345131', 100, '2026-03-11', 2, '宫保鸡丁', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (313, 'NORMAL', NULL, '2026-03-12 08:31:55.345131', 0, '2026-03-11', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (314, 'NORMAL', NULL, '2026-03-12 08:31:55.346134', 100, '2026-03-11', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (315, 'NORMAL', NULL, '2026-03-12 08:31:55.346134', 100, '2026-03-11', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (316, 'NORMAL', NULL, '2026-03-12 08:31:55.347135', 100, '2026-03-11', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (317, 'NORMAL', NULL, '2026-03-12 08:31:55.347135', 100, '2026-03-11', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (318, 'NORMAL', NULL, '2026-03-12 08:31:55.348135', 59, '2026-03-11', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (319, 'NORMAL', NULL, '2026-03-12 08:31:55.348135', 73, '2026-03-11', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (320, 'NORMAL', NULL, '2026-03-12 08:31:55.349135', 0, '2026-03-11', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (321, 'NORMAL', NULL, '2026-03-12 08:31:55.349135', 185, '2026-03-11', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (322, 'NORMAL', NULL, '2026-03-12 08:31:55.349135', 149, '2026-03-11', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (323, 'NORMAL', NULL, '2026-03-12 08:31:55.350135', 163, '2026-03-11', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (324, 'NORMAL', NULL, '2026-03-12 08:31:55.350135', 186, '2026-03-11', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (325, 'NORMAL', NULL, '2026-03-12 08:31:55.351135', 188, '2026-03-11', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (326, 'NORMAL', NULL, '2026-03-12 08:31:55.351135', 199, '2026-03-11', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (327, 'NORMAL', NULL, '2026-03-12 08:31:55.352136', 174, '2026-03-11', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (328, 'NORMAL', NULL, '2026-03-12 08:31:55.352136', 69, '2026-03-11', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (329, 'NORMAL', NULL, '2026-03-12 08:31:55.353135', 63, '2026-03-11', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (330, 'NORMAL', NULL, '2026-03-12 08:31:55.353642', 108, '2026-03-11', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (331, 'NORMAL', NULL, '2026-03-12 08:31:55.354651', 161, '2026-03-11', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (332, 'NORMAL', NULL, '2026-03-12 08:31:55.354651', 65, '2026-03-11', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (333, 'NORMAL', NULL, '2026-03-12 08:31:55.354651', 0, '2026-03-11', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (334, 'NORMAL', NULL, '2026-03-12 08:31:55.355648', 57, '2026-03-11', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (335, 'NORMAL', NULL, '2026-03-12 08:31:55.355648', 0, '2026-03-11', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (336, 'NORMAL', NULL, '2026-03-12 08:31:55.356648', 133, '2026-03-11', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (337, 'NORMAL', NULL, '2026-03-12 08:31:55.356648', 127, '2026-03-11', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (338, 'NORMAL', NULL, '2026-03-12 08:31:55.356648', 92, '2026-03-11', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (339, 'NORMAL', NULL, '2026-03-12 08:31:55.358152', 166, '2026-03-11', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (340, 'NORMAL', NULL, '2026-03-12 08:31:55.358152', 148, '2026-03-11', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (341, 'NORMAL', NULL, '2026-03-12 08:31:55.358743', 116, '2026-03-11', 32, '叫花鸡', 116, 0, 116);

-- ----------------------------
-- Table structure for dish_id_mapping
-- ----------------------------
DROP TABLE IF EXISTS `dish_id_mapping`;
CREATE TABLE `dish_id_mapping`  (
  `old_id` bigint NULL DEFAULT NULL,
  `new_id` bigint NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of dish_id_mapping
-- ----------------------------
INSERT INTO `dish_id_mapping` VALUES (1, 1);
INSERT INTO `dish_id_mapping` VALUES (2, 2);
INSERT INTO `dish_id_mapping` VALUES (3, 3);
INSERT INTO `dish_id_mapping` VALUES (4, 4);
INSERT INTO `dish_id_mapping` VALUES (5, 5);
INSERT INTO `dish_id_mapping` VALUES (6, 6);
INSERT INTO `dish_id_mapping` VALUES (7, 7);
INSERT INTO `dish_id_mapping` VALUES (10, 8);
INSERT INTO `dish_id_mapping` VALUES (11, 9);
INSERT INTO `dish_id_mapping` VALUES (12, 10);
INSERT INTO `dish_id_mapping` VALUES (13, 11);

-- ----------------------------
-- Table structure for dish_taste_tags
-- ----------------------------
DROP TABLE IF EXISTS `dish_taste_tags`;
CREATE TABLE `dish_taste_tags`  (
  `dish_id` bigint NOT NULL,
  `taste_tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `taste_tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `idx_dish_id`(`dish_id` ASC) USING BTREE,
  CONSTRAINT `dish_taste_tags_ibfk_1` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品口味标签表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of dish_taste_tags
-- ----------------------------
INSERT INTO `dish_taste_tags` VALUES (11, '香', NULL);
INSERT INTO `dish_taste_tags` VALUES (11, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (11, '鲜', NULL);
INSERT INTO `dish_taste_tags` VALUES (16, '咸香', NULL);
INSERT INTO `dish_taste_tags` VALUES (16, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (22, '咸香', NULL);
INSERT INTO `dish_taste_tags` VALUES (22, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (10, '鲜', NULL);
INSERT INTO `dish_taste_tags` VALUES (10, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (10, '嫩', NULL);
INSERT INTO `dish_taste_tags` VALUES (1, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (1, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (2, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (2, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (3, '辣', NULL);
INSERT INTO `dish_taste_tags` VALUES (3, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (4, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (4, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (5, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (5, '辣', NULL);
INSERT INTO `dish_taste_tags` VALUES (6, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (6, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (7, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (7, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (8, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (8, '辣', NULL);
INSERT INTO `dish_taste_tags` VALUES (12, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (12, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (13, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (14, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (17, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (17, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (18, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (19, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (19, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (21, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (23, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (23, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (25, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (25, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (27, '辣', NULL);
INSERT INTO `dish_taste_tags` VALUES (27, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (28, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (29, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (29, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (30, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (30, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (31, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (32, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (34, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (9, '咸香', NULL);
INSERT INTO `dish_taste_tags` VALUES (9, '重口味', NULL);
INSERT INTO `dish_taste_tags` VALUES (26, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (26, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (24, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (24, '甜', NULL);

-- ----------------------------
-- Table structure for dishes
-- ----------------------------
DROP TABLE IF EXISTS `dishes`;
CREATE TABLE `dishes`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `price` decimal(38, 2) NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品图片',
  `window_id` bigint NOT NULL COMMENT '所属窗口',
  `calories` int NULL DEFAULT NULL COMMENT '卡路里',
  `protein` decimal(38, 2) NULL DEFAULT NULL,
  `fat` decimal(38, 2) NULL DEFAULT NULL,
  `carbohydrate` decimal(38, 2) NULL DEFAULT NULL,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'AVAILABLE',
  `stock` int NULL DEFAULT NULL COMMENT '库存数量',
  `daily_limit` int NULL DEFAULT NULL COMMENT '每日限量',
  `is_promotion` tinyint(1) NULL DEFAULT 0 COMMENT '是否促销',
  `promotion_price` decimal(38, 2) NULL DEFAULT NULL,
  `promotion_start` datetime NULL DEFAULT NULL COMMENT '促销开始时间',
  `promotion_end` datetime NULL DEFAULT NULL COMMENT '促销结束时间',
  `average_rating` double NULL DEFAULT 0 COMMENT '平均评分',
  `rating_count` int NULL DEFAULT 0 COMMENT '评分次数',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `canteen_id` bigint NULL DEFAULT NULL,
  `canteen_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `window_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `window_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `dish_category` enum('BEVERAGE','MAIN_DISH','SIDE_DISH','SNACK','SOUP','MEAT_DISH','VEGETABLE') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `gift_dish_id` bigint NULL DEFAULT NULL,
  `promotion_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_window_id`(`window_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_is_promotion`(`is_promotion` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of dishes
-- ----------------------------
INSERT INTO `dishes` VALUES (1, '红烧肉', '肥瘦相间，酱香浓郁，入口软糯不腻，经典下饭菜。', 12.00, '/uploads/7b08616e-4e8f-4416-b977-1594c25a13b3.jpg', 1, 350, 15.20, 20.50, 12.30, 'AVAILABLE', 100, 0, 1, 9.60, '2026-02-09 00:00:00', '2026-03-13 00:00:00', 5, 1, '2025-12-24 15:11:32', '2026-02-11 20:31:19', 1, '第一食堂', '一楼东侧', '上海菜窗口', 'MEAT_DISH', NULL, 'discount');
INSERT INTO `dishes` VALUES (2, '宫保鸡丁', '鸡丁鲜嫩，花生香脆，酸甜微辣，口感层次丰富。', 10.00, '/uploads/5406bcfd-634e-461b-8961-fb28e4db4150.jpg', 12, 280, 18.50, 12.20, 15.60, 'AVAILABLE', 100, 100, 1, 9.50, '2026-02-11 00:00:00', '2026-02-28 00:00:00', 5, 2, '2025-12-24 15:11:32', '2026-03-11 15:01:23', 2, '第二食堂', '一楼西侧', '川菜窗口', 'MEAT_DISH', NULL, 'discount');
INSERT INTO `dishes` VALUES (3, '麻婆豆腐', '麻辣鲜香，豆腐嫩滑入味，搭配米饭更过瘾。', 8.00, '/uploads/b410b22a-a5e5-4ef3-bacd-f444fd00ebd3.jpg', 20, 180, 8.20, 10.10, 12.50, 'AVAILABLE', 98, 100, 1, 7.60, '2026-02-11 00:00:00', '2026-02-28 00:00:00', 0, 0, '2025-12-24 15:11:32', '2026-03-23 11:51:19', 3, '第三食堂', '一楼南侧', '川菜窗口', 'VEGETABLE', NULL, 'discount');
INSERT INTO `dishes` VALUES (4, '西红柿鸡蛋', '家常经典，酸甜开胃，鸡蛋滑嫩，清爽不油腻。', 7.00, '/uploads/b97ef2fd-6801-416c-a344-101deaeac257.png', 6, 150, 9.10, 8.30, 10.20, 'AVAILABLE', 100, 100, 0, 6.65, '2026-02-11 00:00:00', '2026-02-28 00:00:00', 0, 0, '2025-12-24 15:11:32', '2026-02-19 20:24:35', 1, '第一食堂', '二楼东侧', '特色菜窗口', 'VEGETABLE', NULL, 'discount');
INSERT INTO `dishes` VALUES (5, '青椒土豆丝', '脆爽清香，咸鲜适口，简单家常却很下饭。', 5.00, '/uploads/f821ed7a-8e24-4751-a02e-efecaf3d2814.jpg', 15, 80, 2.10, 0.50, 18.20, 'AVAILABLE', 98, 100, 0, 4.75, '2026-02-11 00:00:00', '2026-02-28 00:00:00', 0, 0, '2025-12-24 15:11:32', '2026-03-23 11:51:19', 2, '第二食堂', '二楼西侧', '特色菜窗口', 'VEGETABLE', NULL, 'discount');
INSERT INTO `dishes` VALUES (6, '紫菜蛋花汤', '清淡鲜美，汤汁顺口，暖胃舒适，搭配主食更合适。', 3.00, '/uploads/88a71dfc-fbc2-467a-8390-09422c8d0d87.jpg', 21, 50, 3.20, 1.80, 2.50, 'AVAILABLE', 100, 100, 0, NULL, NULL, NULL, 4, 1, '2025-12-24 15:11:32', '2026-02-21 20:14:52', 3, '第三食堂', '二楼南侧', '汤品窗口', 'SOUP', NULL, NULL);
INSERT INTO `dishes` VALUES (7, '鱼香肉丝', '酸甜微辣，肉丝爽滑，酱香浓郁，开胃下饭。', 10.00, '/uploads/98147ca8-bd76-4d6c-8324-6f160dc314d3.png', 2, 104, 13.40, 5.30, 22.20, 'AVAILABLE', 59, 59, 0, 10.00, NULL, NULL, 4, 2, '2025-12-24 15:11:32', '2026-02-19 21:05:54', 1, '第一食堂', '三楼东侧', '川菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (8, '清蒸鱼', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 20.00, '/uploads/356ae620-4d79-405e-a8f2-446be5ad0005.jpg', 15, 252, 13.40, 7.90, 24.70, 'AVAILABLE', 73, 73, 0, 15.00, NULL, NULL, 0, 0, '2025-12-24 15:11:32', '2026-03-02 11:40:49', 2, '第二食堂', '三楼西侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (9, '清真牛肉饭', '精选牛肉，搭配米饭', 16.00, '/uploads/f12f549d-0103-41cb-8583-a11534e680a0.jpg', 23, 153, 5.60, 14.00, 36.80, 'AVAILABLE', 110, 0, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 12:04:16', 3, '第三食堂', '三楼南侧', '清真窗口', 'MAIN_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (10, '包子', '传统面食，多种馅料', 2.00, '/uploads/b5364337-aec2-4ff3-8b83-aee27b3991db.jpg', 3, 364, 16.00, 12.40, 48.60, 'AVAILABLE', 185, 185, 0, 2.00, NULL, NULL, 0, 0, '2025-12-24 15:11:32', '2026-02-19 20:08:46', 1, '第一食堂', '一楼西侧', '早餐窗口', 'SNACK', 11, 'gift');
INSERT INTO `dishes` VALUES (11, '油条', '早餐必备，酥脆可口', 1.50, '/uploads/c37da0e0-ff7a-4edc-9196-5e9773f64f6b.png', 13, 251, 11.30, 3.60, 18.70, 'AVAILABLE', 149, 149, 0, NULL, NULL, NULL, 0, 0, '2025-12-24 15:11:32', '2026-02-10 14:25:31', 2, '第二食堂', '一楼西侧', '早餐窗口', 'SNACK', NULL, NULL);
INSERT INTO `dishes` VALUES (12, '回锅肉', '肥而不腻，蒜苗提香，香辣过瘾，经典川味。', 28.00, '/uploads/4c94eb2c-e708-4604-a41b-facfdcf87276.jpg', 2, 150, 10.30, 16.00, 22.10, 'AVAILABLE', 163, 163, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 1, '第一食堂', '二楼东侧', '川菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (13, '白切鸡', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 38.00, '/uploads/b865e44a-e1b2-44fc-8444-55056406b0c6.jpg', 17, 178, 10.30, 17.10, 42.00, 'AVAILABLE', 186, 186, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 2, '第二食堂', '二楼西侧', '粤菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (14, '广东菜心', '清爽不腻，口感自然，家常做法，健康又好吃。', 16.00, '/uploads/ef5ba583-6157-4891-8cb6-862a66530200.jpg', 26, 339, 10.10, 10.70, 39.20, 'AVAILABLE', 186, 188, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-03-23 11:51:19', 3, '第三食堂', '二楼南侧', '粤菜窗口', 'VEGETABLE', NULL, NULL);
INSERT INTO `dishes` VALUES (16, '烧腊饭', '经典粤菜，香气四溢', 32.00, '/uploads/dcbeb7ef-7ea8-440b-b541-23b43e172a29.jpg', 8, 140, 18.20, 11.40, 32.20, 'AVAILABLE', 199, 199, 0, NULL, NULL, NULL, 0, 0, '2025-12-24 15:11:32', '2026-02-11 22:44:53', 1, '第一食堂', '三楼东侧', '粤菜窗口', 'MAIN_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (17, '糖醋里脊', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 35.00, '/uploads/1552a1e6-3304-4b82-8c3f-541feeb2b182.png', 15, 117, 8.60, 17.80, 41.10, 'AVAILABLE', 174, 174, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 2, '第二食堂', '三楼西侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (18, '葱爆羊肉', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 42.00, '/uploads/71c4e6e8-5bd7-4a94-9ebd-0fdfba641077.jpg', 25, 331, 16.50, 10.70, 34.60, 'AVAILABLE', 69, 69, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 3, '第三食堂', '三楼南侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (19, '油焖大虾', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 48.00, '/uploads/3a3b9cec-f73f-4f4f-9615-a1d3a90edfe2.jpg', 10, 110, 11.80, 8.50, 35.80, 'AVAILABLE', 63, 63, 0, NULL, NULL, NULL, 5, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 1, '第一食堂', '一楼东侧', '鲁菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (21, '清炒时蔬', '清爽不腻，口感自然，家常做法，健康又好吃。', 15.00, '/uploads/e331c11a-2f62-4eb9-8c03-075883055426.jpg', 25, 186, 13.00, 2.30, 14.10, 'AVAILABLE', 108, 108, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 3, '第三食堂', '一楼南侧', '特色菜窗口', 'VEGETABLE', NULL, NULL);
INSERT INTO `dishes` VALUES (22, '西红柿鸡蛋面', '经典面食，酸甜可口', 12.00, '/uploads/4e9d3ecf-c911-4567-a96f-bc5dc04852ef.jpg', 9, 137, 6.40, 5.90, 49.50, 'AVAILABLE', 161, 161, 0, NULL, NULL, NULL, 0, 0, '2025-12-24 15:11:32', '2026-02-11 22:44:53', 1, '第一食堂', '二楼东侧', '面食窗口', 'MAIN_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (23, '小笼包', '外酥里嫩，香气十足，适合作为加餐或解馋小吃。', 10.00, '/uploads/4ad40111-de98-441f-9bc6-8ad6f21f0af2.jpg', 11, 202, 13.80, 7.40, 49.50, 'AVAILABLE', 65, 65, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-19 21:05:54', 2, '第二食堂', '二楼西侧', '上海菜窗口', 'SNACK', NULL, NULL);
INSERT INTO `dishes` VALUES (24, '松鼠桂鱼', '造型美观，外酥里嫩', 68.00, '/uploads/cebcdf1e-f91d-424e-9b88-4a0e9f792f03.jpg', 27, 367, 8.20, 19.10, 39.90, 'AVAILABLE', 159, 0, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-11 14:36:14', 3, '第三食堂', '二楼南侧', '苏菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (25, '清炒虾仁', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 58.00, '/uploads/f9fd92ab-9a74-41bb-935e-6382006713c0.jpg', 6, 210, 10.30, 13.60, 46.70, 'AVAILABLE', 57, 57, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 1, '第一食堂', '三楼东侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (26, '扬州炒饭', '颗粒分明，营养丰富', 22.00, '/uploads/fc46df66-155c-4dd0-a4fe-d153a9187219.jpg', 16, 168, 8.40, 9.10, 32.30, 'AVAILABLE', 185, 0, 0, NULL, NULL, NULL, 0, 0, '2025-12-24 15:11:32', '2026-02-18 21:48:27', 2, '第二食堂', '三楼西侧', '盖浇饭窗口', 'MAIN_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (27, '剁椒鱼头', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 58.00, '/uploads/6a966b06-0025-472a-91ac-ae63fa97097d.jpg', 24, 330, 11.90, 15.90, 14.10, 'AVAILABLE', 133, 133, 0, NULL, NULL, NULL, 4, 1, '2025-12-24 15:11:32', '2026-02-19 21:05:54', 3, '第三食堂', '三楼南侧', '湘菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (28, '农家小炒肉', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 32.00, '/uploads/0d05a268-45e9-4891-9d8a-5fcb840894b8.png', 5, 222, 6.10, 16.20, 11.40, 'AVAILABLE', 127, 127, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-02-19 21:05:54', 1, '第一食堂', '一楼东侧', '湘菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (29, '永州血鸭', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 45.00, '/uploads/30144d1a-1e1e-4ee5-b69e-a29b306569f6.jpg', 14, 317, 5.30, 19.00, 22.20, 'AVAILABLE', 92, 92, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 2, '第二食堂', '一楼西侧', '湘菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (30, '西湖醋鱼', '酸甜可口，鱼香四溢', 48.00, '/uploads/dbec63d4-ff3d-430e-ac3b-e71e87c468b8.jpg', 22, 183, 6.80, 13.00, 41.50, 'AVAILABLE', 166, 166, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 3, '第三食堂', '一楼南侧', '浙菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (31, '龙井虾仁', '茶香四溢，虾仁鲜甜可口', 68.00, '/uploads/b9cb4f4d-dfdc-4099-b805-283aa0e1d77d.jpg', 4, 204, 14.00, 12.10, 42.10, 'AVAILABLE', 148, 148, 0, NULL, NULL, NULL, 4, 10, '2025-12-24 15:11:32', '2026-02-19 21:06:18', 1, '第一食堂', '二楼东侧', '浙菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (32, '叫花鸡', '肉香浓郁，咸鲜入味，口感丰富', 52.00, '/uploads/c8d3de73-ddff-4cc1-a840-a2eb74147d9d.jpg', 18, 202, 16.80, 14.30, 15.50, 'AVAILABLE', 116, 116, 0, NULL, NULL, NULL, 0, 0, '2025-12-24 15:11:32', '2026-02-10 10:59:44', 2, '第二食堂', '二楼西侧', '苏菜窗口', 'MEAT_DISH', NULL, NULL);
INSERT INTO `dishes` VALUES (34, '奶茶', '清爽解渴，口感舒适，搭配餐食更畅快。', 18.00, '/uploads/7485f557-54c1-40be-8667-a25016e0aa5e.jpg', 7, 243, 6.10, 10.60, 41.90, 'AVAILABLE', 119, 119, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-03-11 15:01:30', 1, '第一食堂', '三楼东侧', '甜品窗口', 'BEVERAGE', NULL, NULL);

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `biz_id` bigint NULL DEFAULT NULL,
  `biz_type` enum('DISH','ORDER','PROMOTION','REVIEW','REWARD_EXCHANGE') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime(6) NOT NULL,
  `deleted` bit(1) NOT NULL,
  `is_read` bit(1) NOT NULL,
  `read_time` datetime(6) NULL DEFAULT NULL,
  `scene` enum('COMMENT_REPLY','DISH_ON_SHELF','INVENTORY_WARNING','ORDER_STATUS_CHANGE','PROMOTION_START','REWARD_DELIVERY') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` enum('COMMENT','DISH','PROMOTION','RESERVATION','REWARD','WARNING') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_notifications_user_read_time`(`user_id` ASC, `is_read` ASC, `create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 674 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (71, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.125305', b'1', b'1', '2026-02-03 21:55:24.348192', 'DISH_ON_SHELF', '菜品上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (72, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.161025', b'0', b'1', '2026-02-04 11:29:55.792124', 'DISH_ON_SHELF', '菜品上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (73, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.164092', b'1', b'1', '2026-02-04 11:30:19.283598', 'DISH_ON_SHELF', '菜品上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (74, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.165890', b'0', b'1', '2026-02-04 10:05:25.325421', 'DISH_ON_SHELF', '菜品上架', 'DISH', 4);
INSERT INTO `notifications` VALUES (75, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.167860', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (76, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.169915', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 6);
INSERT INTO `notifications` VALUES (77, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.170935', b'0', b'1', '2026-02-04 11:30:32.570993', 'DISH_ON_SHELF', '菜品上架', 'DISH', 7);
INSERT INTO `notifications` VALUES (78, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.173892', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (79, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.181118', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (80, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.184196', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (81, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.187228', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (82, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.190267', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 12);
INSERT INTO `notifications` VALUES (83, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.192793', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 13);
INSERT INTO `notifications` VALUES (84, 1, 'DISH', '菜品【红烧肉】已上架，快去看看吧！', '2026-02-03 21:55:18.194814', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 14);
INSERT INTO `notifications` VALUES (85, 55, 'ORDER', '订单【ORD1770127046202】支付成功，已为您安排制作。', '2026-02-03 21:57:30.825771', b'1', b'1', '2026-02-03 21:57:58.434198', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (86, 55, 'ORDER', '您的订单【ORD1770127046202】商家已接单，正在为您制作中。', '2026-02-03 21:57:44.637148', b'1', b'1', '2026-02-03 21:57:58.778960', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (87, 55, 'ORDER', '您的预约订单【ORD1770127046202】已制作完成，预约取餐时间 23:57，请准时到达取餐口。', '2026-02-03 21:57:47.049130', b'1', b'1', '2026-02-03 21:57:59.119542', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (88, 55, 'ORDER', '您的订单【ORD1770127046202】已完成，感谢您的光临！', '2026-02-03 22:11:26.068078', b'1', b'1', '2026-02-03 22:20:07.924946', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (89, 23, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-03 22:11:32.901241', b'1', b'1', '2026-02-03 22:19:55.869430', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (90, 23, 'REVIEW', '食堂回复了您的评价：感谢您的评价', '2026-02-03 22:11:49.893362', b'1', b'1', '2026-02-03 22:19:46.794166', 'COMMENT_REPLY', '您的评价有新回复', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (91, 19, 'ORDER', '您的订单【ORD176889886302018】商家已接单，正在为您制作中。', '2026-02-03 22:41:40.780924', b'1', b'1', '2026-02-03 22:42:58.115797', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (92, 19, 'ORDER', '您的订单【ORD176889886302018】已制作完成，请前往取餐口取餐。', '2026-02-03 22:41:42.071479', b'1', b'1', '2026-02-03 22:42:58.115797', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (93, 19, 'ORDER', '您的订单【ORD176889886302018】已完成，感谢您的光临！', '2026-02-03 22:41:43.213489', b'1', b'1', '2026-02-03 22:42:58.115797', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (94, 54, 'ORDER', '订单【ORD1770112635550】支付成功，已为您安排制作。', '2026-02-03 22:42:22.982442', b'1', b'1', '2026-02-04 11:30:19.283598', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (95, 54, 'ORDER', '您的订单【ORD1770112635550】商家已接单，正在为您制作中。', '2026-02-03 22:42:49.341878', b'1', b'1', '2026-02-04 11:30:19.283598', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (96, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.518165', b'1', b'1', '2026-02-04 15:59:39.016147', 'DISH_ON_SHELF', '菜品上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (97, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.543706', b'0', b'1', '2026-02-04 11:29:55.792124', 'DISH_ON_SHELF', '菜品上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (98, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.546364', b'1', b'1', '2026-02-04 11:30:19.283598', 'DISH_ON_SHELF', '菜品上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (99, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.548691', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 4);
INSERT INTO `notifications` VALUES (100, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.551974', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (101, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.553509', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 6);
INSERT INTO `notifications` VALUES (102, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.557370', b'0', b'1', '2026-02-04 11:30:32.570993', 'DISH_ON_SHELF', '菜品上架', 'DISH', 7);
INSERT INTO `notifications` VALUES (103, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.560434', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (104, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.563091', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (105, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.564752', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (106, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.568044', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (107, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.571001', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 12);
INSERT INTO `notifications` VALUES (108, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.573045', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 13);
INSERT INTO `notifications` VALUES (109, 10, 'DISH', '菜品【包子】已上架，快去看看吧！', '2026-02-04 10:51:52.576200', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 14);
INSERT INTO `notifications` VALUES (110, 54, 'ORDER', '您的订单【ORD1770112635550】已制作完成，请前往取餐口取餐。', '2026-02-04 10:52:02.535824', b'1', b'1', '2026-02-04 11:30:19.283598', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (115, 24, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-04 11:31:19.037941', b'0', b'0', NULL, 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 7);
INSERT INTO `notifications` VALUES (116, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.068553', b'1', b'1', '2026-02-04 15:59:39.016147', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (117, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.070101', b'0', b'1', '2026-02-09 11:51:55.037316', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (118, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.072889', b'1', b'1', '2026-02-05 17:07:54.845557', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (119, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.074751', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (120, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.076142', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (121, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.077993', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 6);
INSERT INTO `notifications` VALUES (122, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.079740', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (123, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.080743', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (124, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.082385', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (125, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.085158', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (126, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.087106', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (127, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.088112', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (128, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.089664', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 13);
INSERT INTO `notifications` VALUES (129, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-04 11:36:00.092439', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 14);
INSERT INTO `notifications` VALUES (130, 57, 'ORDER', '订单【ORD1770182084045】支付成功，已为您安排制作。', '2026-02-04 16:00:02.157921', b'1', b'1', '2026-02-04 16:01:14.056683', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (131, 25, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-04 16:00:36.327874', b'1', b'1', '2026-02-04 16:01:14.056683', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (135, 27, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-04 16:35:45.579485', b'1', b'1', '2026-02-04 17:16:23.401517', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (136, 27, 'REVIEW', '检测到低评分或负面关键词评价，评价ID：27，评分：1.3，评价内容：很难吃，环境很差，卫生很差', '2026-02-04 16:35:45.678689', b'1', b'1', '2026-02-04 17:01:18.246929', 'COMMENT_REPLY', '评价预警', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (137, 28, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-04 17:01:47.071524', b'1', b'1', '2026-02-04 17:16:23.401517', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (138, 28, 'REVIEW', '检测到低评分或负面关键词评价，评价ID：28，评分：1.3', '2026-02-04 17:01:47.160166', b'1', b'1', '2026-02-04 17:15:53.926435', 'COMMENT_REPLY', '评价预警', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (139, 58, 'ORDER', '订单【ORD1770274265242】支付成功，已为您安排制作。', '2026-02-05 14:51:06.612437', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (140, 58, 'ORDER', '您的订单【ORD1770274265242】商家已接单，正在为您制作中。', '2026-02-05 14:51:14.084279', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (141, 58, 'ORDER', '您的订单【ORD1770274265242】已制作完成，请前往取餐口取餐。', '2026-02-05 14:51:15.439238', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (142, 58, 'ORDER', '您的订单【ORD1770274265242】已完成，感谢您的光临！', '2026-02-05 14:51:16.863470', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (159, 63, 'ORDER', '订单【ORD1770383386870】支付成功，已为您安排制作。', '2026-02-06 21:09:59.196910', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (160, 63, 'ORDER', '您的订单【ORD1770383386870】商家已接单，正在为您制作中。', '2026-02-06 21:10:07.866701', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (161, 63, 'ORDER', '您的订单【ORD1770383386870】已制作完成，请前往取餐口取餐。', '2026-02-06 21:10:09.097381', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (162, 63, 'ORDER', '您的订单【ORD1770383386870】已完成，感谢您的光临！', '2026-02-06 21:10:13.498453', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (163, 64, 'ORDER', '订单【ORD1770383423562】支付成功，已为您安排制作。', '2026-02-06 21:10:24.443435', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (164, 64, 'ORDER', '您的订单【ORD1770383423562】商家已接单，正在为您制作中。', '2026-02-06 21:10:31.085352', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (165, 64, 'ORDER', '您的订单【ORD1770383423562】已制作完成，请前往取餐口取餐。', '2026-02-06 21:10:32.223755', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (166, 64, 'ORDER', '您的订单【ORD1770383423562】已完成，感谢您的光临！', '2026-02-06 21:10:33.355550', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (167, 65, 'ORDER', '订单【ORD1770383454300】支付成功，已为您安排制作。', '2026-02-06 21:10:55.136088', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (168, 65, 'ORDER', '您的订单【ORD1770383454300】商家已接单，正在为您制作中。', '2026-02-06 21:11:01.555658', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (169, 65, 'ORDER', '您的订单【ORD1770383454300】已制作完成，请前往取餐口取餐。', '2026-02-06 21:11:02.963956', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (170, 65, 'ORDER', '您的订单【ORD1770383454300】已完成，感谢您的光临！', '2026-02-06 21:11:04.164295', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (171, 66, 'ORDER', '订单【ORD1770383937106】支付成功，已为您安排制作。', '2026-02-06 21:18:58.838796', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (172, 66, 'ORDER', '您的订单【ORD1770383937106】商家已接单，正在为您制作中。', '2026-02-06 21:19:09.916946', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (173, 66, 'ORDER', '您的订单【ORD1770383937106】已制作完成，请前往取餐口取餐。', '2026-02-06 21:19:11.262865', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (174, 66, 'ORDER', '您的订单【ORD1770383937106】已完成，感谢您的光临！', '2026-02-06 21:35:44.889924', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (178, 68, 'ORDER', '订单【ORD1770386145560】支付成功，已为您安排制作。', '2026-02-06 21:55:46.792864', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (179, 68, 'ORDER', '您的订单【ORD1770386145560】商家已接单，正在为您制作中。', '2026-02-06 21:55:51.493259', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (180, 68, 'ORDER', '您的订单【ORD1770386145560】已制作完成，请前往取餐口取餐。', '2026-02-06 21:55:54.814951', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (181, 68, 'ORDER', '您的订单【ORD1770386145560】已完成，感谢您的光临！', '2026-02-06 22:17:56.142916', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (183, 69, 'ORDER', '订单【ORD1770387792782】支付成功，已为您安排制作。', '2026-02-06 22:23:14.222984', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (184, 69, 'ORDER', '您的订单【ORD1770387792782】商家已接单，正在为您制作中。', '2026-02-06 22:23:19.280447', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (185, 69, 'ORDER', '您的订单【ORD1770387792782】已制作完成，请前往取餐口取餐。', '2026-02-06 22:23:20.828385', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (186, 69, 'ORDER', '您的订单【ORD1770387792782】已完成，感谢您的光临！', '2026-02-06 22:23:21.750970', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (187, 70, 'ORDER', '订单【ORD1770387821949】支付成功，已为您安排制作。', '2026-02-06 22:23:43.458875', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (188, 70, 'ORDER', '您的订单【ORD1770387821949】商家已接单，正在为您制作中。', '2026-02-06 22:23:50.028705', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (189, 70, 'ORDER', '您的订单【ORD1770387821949】已制作完成，请前往取餐口取餐。', '2026-02-06 22:23:51.624599', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (190, 70, 'ORDER', '您的订单【ORD1770387821949】已完成，感谢您的光临！', '2026-02-06 22:23:52.904517', b'1', b'1', '2026-02-07 11:29:40.579354', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (191, 29, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-06 22:24:11.232758', b'1', b'1', '2026-02-07 11:29:40.579354', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (200, 9, 'ORDER', '您的订单【ORD17688988629078】已制作完成，请前往取餐口取餐。', '2026-02-07 14:18:31.924738', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (201, 9, 'ORDER', '您的订单【ORD17688988629078】已完成，感谢您的光临！', '2026-02-07 14:18:32.954255', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (202, 3, 'REWARD_EXCHANGE', '您的奖品【百科全书】已经发货啦！', '2026-02-07 15:18:54.570693', b'1', b'1', '2026-02-07 15:19:29.199493', 'REWARD_DELIVERY', '奖品已发货', 'REWARD', 1);
INSERT INTO `notifications` VALUES (203, 3, 'REWARD_EXCHANGE', '您的奖品【百科全书】已送达，请注意查收。', '2026-02-07 15:19:11.672754', b'1', b'1', '2026-02-07 15:19:30.863066', 'REWARD_DELIVERY', '奖品已送达', 'REWARD', 1);
INSERT INTO `notifications` VALUES (204, 2, 'REWARD_EXCHANGE', '您的奖品【数字周边礼包】已经发货啦！物流信息：顺丰快递发货', '2026-02-07 15:19:24.269552', b'1', b'1', '2026-02-07 15:19:34.582555', 'REWARD_DELIVERY', '奖品已发货', 'REWARD', 1);
INSERT INTO `notifications` VALUES (205, 30, 'REVIEW', '感谢您的评价！您获得了 30 积分奖励。', '2026-02-07 20:40:24.130873', b'1', b'1', '2026-02-07 23:26:47.935624', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (210, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.255656', b'1', b'1', '2026-02-07 23:26:47.935624', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (211, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.298336', b'0', b'1', '2026-02-09 11:51:55.037316', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (212, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.305253', b'1', b'1', '2026-02-07 23:00:00.616831', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (213, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.306886', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 4);
INSERT INTO `notifications` VALUES (214, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.308495', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (215, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.310604', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 6);
INSERT INTO `notifications` VALUES (216, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.312277', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 7);
INSERT INTO `notifications` VALUES (217, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.319097', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (218, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.321442', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (219, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.327055', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (220, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.332918', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (221, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.339965', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 12);
INSERT INTO `notifications` VALUES (222, 10, 'DISH', '新菜品【包子】已上线，快去看看吧！', '2026-02-07 22:17:41.348015', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 13);
INSERT INTO `notifications` VALUES (228, 31, 'REVIEW', '感谢您的评价！您获得了 30 积分奖励。', '2026-02-07 22:57:58.826071', b'1', b'1', '2026-02-07 23:00:18.801627', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 3);
INSERT INTO `notifications` VALUES (230, 75, 'ORDER', '订单【ORD1770477849290】支付成功，已为您安排制作。', '2026-02-07 23:24:10.505152', b'1', b'1', '2026-02-07 23:26:47.935624', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (231, 75, 'ORDER', '您的订单【ORD1770477849290】商家已接单，正在为您制作中。', '2026-02-07 23:24:15.494391', b'1', b'1', '2026-02-07 23:26:47.935624', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (232, 75, 'ORDER', '您的订单【ORD1770477849290】已制作完成，请前往取餐口取餐。', '2026-02-07 23:24:16.515175', b'1', b'1', '2026-02-07 23:26:47.935624', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (233, 75, 'ORDER', '您的订单【ORD1770477849290】已完成，感谢您的光临！', '2026-02-07 23:24:17.538237', b'1', b'1', '2026-02-07 23:26:47.935624', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (234, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.368181', b'1', b'1', '2026-02-07 23:26:47.935624', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (235, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.369804', b'0', b'1', '2026-02-09 11:51:55.037316', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (236, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.373170', b'1', b'1', '2026-02-10 15:24:35.562153', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (237, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.374749', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 4);
INSERT INTO `notifications` VALUES (238, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.377220', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (239, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.379129', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 6);
INSERT INTO `notifications` VALUES (240, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.381135', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 7);
INSERT INTO `notifications` VALUES (241, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.386869', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (242, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.389075', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (243, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.390077', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (244, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.391585', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (245, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.393108', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 12);
INSERT INTO `notifications` VALUES (246, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.395687', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 13);
INSERT INTO `notifications` VALUES (247, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-07 23:26:29.397210', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 24);
INSERT INTO `notifications` VALUES (248, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.376209', b'1', b'1', '2026-02-09 12:05:49.894206', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (249, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.377734', b'0', b'1', '2026-02-09 11:51:55.037316', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (250, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.379242', b'1', b'1', '2026-02-10 15:24:35.562153', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (251, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.382182', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 4);
INSERT INTO `notifications` VALUES (252, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.383716', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (253, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.385238', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 6);
INSERT INTO `notifications` VALUES (254, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.385744', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 7);
INSERT INTO `notifications` VALUES (255, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.387253', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (256, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.388255', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (257, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.388762', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (258, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.390282', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (259, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.391294', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 12);
INSERT INTO `notifications` VALUES (260, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.391804', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 13);
INSERT INTO `notifications` VALUES (261, 2, 'DISH', '新菜品【宫保鸡丁】已上线，快去看看吧！', '2026-02-07 23:26:55.393311', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 24);
INSERT INTO `notifications` VALUES (262, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.106707', b'1', b'1', '2026-02-09 12:05:49.895220', 'DISH_ON_SHELF', '菜品上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (263, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.108602', b'0', b'1', '2026-02-09 11:51:55.037316', 'DISH_ON_SHELF', '菜品上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (264, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.112573', b'1', b'1', '2026-02-10 15:24:35.562153', 'DISH_ON_SHELF', '菜品上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (265, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.114617', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 4);
INSERT INTO `notifications` VALUES (266, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.116681', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (267, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.119102', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 6);
INSERT INTO `notifications` VALUES (268, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.119102', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 7);
INSERT INTO `notifications` VALUES (269, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.122185', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (270, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.123262', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (271, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.125288', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (272, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.126318', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (273, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.127828', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 12);
INSERT INTO `notifications` VALUES (274, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.129927', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 13);
INSERT INTO `notifications` VALUES (275, 40, 'DISH', '菜品【青椒肉丝】已上架，快去看看吧！', '2026-02-07 23:28:42.131452', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品上架', 'DISH', 24);
INSERT INTO `notifications` VALUES (276, 32, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-07 23:44:33.364885', b'1', b'1', '2026-02-09 12:05:49.895220', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (277, 32, 'REVIEW', '检测到低评分或负面关键词评价，评价ID：32，评分：2.0，评价内容：鱼很腥，很难吃，很贵，性价比不高', '2026-02-07 23:44:33.451997', b'1', b'1', '2026-02-07 23:44:37.229986', 'COMMENT_REPLY', '评价预警', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (278, 32, 'REVIEW', '食堂回复了您的评价：很抱歉给您带来不好的体验', '2026-02-07 23:44:52.874206', b'1', b'1', '2026-02-09 12:05:49.895220', 'COMMENT_REPLY', '您的评价有新回复', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (279, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.691286', b'1', b'1', '2026-02-09 12:05:49.895220', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (280, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.696248', b'0', b'1', '2026-02-09 11:51:55.037316', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (281, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.699804', b'1', b'1', '2026-02-10 15:24:35.562153', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (282, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.703035', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (283, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.706868', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (284, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.711904', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (285, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.711904', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (286, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.713456', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (287, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.713456', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (288, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.715371', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (289, 6, 'PROMOTION', '促销【情人节促销】已开始（2026-02-07 00:00 - 2026-03-18 00:00），快来看看吧！', '2026-02-07 23:56:01.716890', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (290, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.204352', b'1', b'1', '2026-02-09 12:05:49.895220', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (291, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.205885', b'0', b'1', '2026-02-09 11:51:55.037316', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (292, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.206893', b'1', b'1', '2026-02-10 15:24:35.562153', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (293, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.208629', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (294, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.210164', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (295, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.211692', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (296, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.211692', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (297, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.213230', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (298, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.214854', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (299, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.216891', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (300, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-07 23:57:34.218603', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (301, 76, 'ORDER', '订单【ORD1770480868519】支付成功，已为您安排制作。', '2026-02-08 00:14:29.961204', b'1', b'1', '2026-02-09 12:05:49.895220', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (302, 5, 'REWARD_EXCHANGE', '您的奖品【数字周边礼包】已经发货啦！物流信息：顺丰快递发货', '2026-02-08 00:14:51.272780', b'1', b'1', '2026-02-09 12:05:49.895220', 'REWARD_DELIVERY', '奖品已发货', 'REWARD', 1);
INSERT INTO `notifications` VALUES (303, 5, 'REWARD_EXCHANGE', '您的奖品【数字周边礼包】已送达，请注意查收。', '2026-02-08 00:15:09.235209', b'1', b'1', '2026-02-09 12:05:49.895220', 'REWARD_DELIVERY', '奖品已送达', 'REWARD', 1);
INSERT INTO `notifications` VALUES (304, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.884801', b'1', b'1', '2026-02-09 12:06:14.970536', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (305, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.888130', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (306, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.889734', b'1', b'1', '2026-02-10 15:24:35.562153', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (307, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.891764', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 4);
INSERT INTO `notifications` VALUES (308, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.895733', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (309, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.897762', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 7);
INSERT INTO `notifications` VALUES (310, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.900293', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (311, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.902331', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (312, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.903862', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (313, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.908032', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (314, 9, 'DISH', '新菜品【清真牛肉饭】已上线，快去看看吧！', '2026-02-09 12:06:07.910027', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 12);
INSERT INTO `notifications` VALUES (315, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.825193', b'1', b'1', '2026-02-09 12:22:42.471028', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (316, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.883089', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (317, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.886771', b'1', b'1', '2026-02-10 15:24:35.562153', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (318, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.889180', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (319, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.905339', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (320, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.909071', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (321, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.916052', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (322, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.918221', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (323, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-02-09 12:22:02.922176', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 12);
INSERT INTO `notifications` VALUES (324, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.403617', b'1', b'1', '2026-02-09 13:46:33.363403', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (325, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.407321', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (326, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.410430', b'1', b'1', '2026-02-10 15:24:35.562153', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (327, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.413708', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (328, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.416562', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (329, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.418824', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (330, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.422077', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (331, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.424347', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (332, 41, 'DISH', '新菜品【3213】上线啦，快去尝鲜吧！', '2026-02-09 12:26:11.427107', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 12);
INSERT INTO `notifications` VALUES (333, 77, 'ORDER', '订单【ORD1770622507104】支付成功，已为您安排制作。', '2026-02-09 15:35:08.550762', b'1', b'1', '2026-02-09 15:37:15.108938', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (334, 76, 'ORDER', '您的订单【ORD1770480868519】商家已接单，正在为您制作中。', '2026-02-09 15:36:34.193392', b'1', b'1', '2026-02-09 15:37:14.353728', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (335, 77, 'ORDER', '您的订单【ORD1770622507104】商家已接单，正在为您制作中。', '2026-02-09 15:36:36.287460', b'1', b'1', '2026-02-09 15:37:07.886922', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (336, 76, 'ORDER', '您的订单【ORD1770480868519】已制作完成，请前往取餐口取餐。', '2026-02-09 15:36:37.935590', b'1', b'1', '2026-02-09 15:37:07.361840', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (337, 77, 'ORDER', '您的订单【ORD1770622507104】已制作完成，请前往取餐口取餐。', '2026-02-09 15:36:39.438934', b'1', b'1', '2026-02-09 15:37:06.676247', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (338, 76, 'ORDER', '您的订单【ORD1770480868519】已完成，感谢您的光临！', '2026-02-09 15:36:42.174664', b'1', b'1', '2026-02-09 15:37:06.042820', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (339, 77, 'ORDER', '您的订单【ORD1770622507104】已完成，感谢您的光临！', '2026-02-09 15:36:43.408835', b'1', b'1', '2026-02-09 15:37:03.855094', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (343, 81, 'ORDER', '订单【ORD1770630320184】支付成功，已为您安排制作。', '2026-02-09 17:45:21.352520', b'1', b'1', '2026-02-09 17:45:41.983150', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (344, 81, 'ORDER', '您的订单【ORD1770630320184】商家已接单，正在为您制作中。', '2026-02-09 17:45:31.655343', b'1', b'1', '2026-02-09 17:45:41.983150', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (345, 81, 'ORDER', '您的订单【ORD1770630320184】已制作完成，请前往取餐口取餐。', '2026-02-09 17:45:32.680243', b'1', b'1', '2026-02-09 17:45:41.983150', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (346, 81, 'ORDER', '您的订单【ORD1770630320184】已完成，感谢您的光临！', '2026-02-09 17:45:33.685252', b'1', b'1', '2026-02-09 17:45:41.983150', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (347, 82, 'ORDER', '订单【ORD1770704570988】支付成功，已为您安排制作。', '2026-02-10 14:22:52.671306', b'1', b'1', '2026-02-10 14:23:21.390061', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (348, 82, 'ORDER', '您的订单【ORD1770704570988】商家已接单，正在为您制作中。', '2026-02-10 14:23:02.000550', b'1', b'1', '2026-02-10 14:23:21.390061', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (349, 82, 'ORDER', '您的订单【ORD1770704570988】已制作完成，请前往取餐口取餐。', '2026-02-10 14:23:03.164093', b'1', b'1', '2026-02-10 14:23:21.390061', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (350, 82, 'ORDER', '您的订单【ORD1770704570988】已完成，感谢您的光临！', '2026-02-10 14:23:04.381938', b'1', b'1', '2026-02-10 14:23:21.390061', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (351, 30, 'REVIEW', '食堂回复了您的评价：感谢评价', '2026-02-10 14:23:12.647189', b'1', b'1', '2026-02-10 14:23:21.390061', 'COMMENT_REPLY', '您的评价有新回复', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (352, 33, 'REVIEW', '感谢您的评价！您获得了 30 积分奖励。', '2026-02-10 14:24:04.307724', b'1', b'1', '2026-02-10 15:24:20.101312', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (353, 34, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-10 14:24:34.353319', b'1', b'1', '2026-02-10 15:24:20.101312', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (354, 54, 'ORDER', '您的订单【ORD1770112635550】已完成，感谢您的光临！', '2026-02-10 15:24:41.611828', b'1', b'1', '2026-02-10 15:25:01.803417', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (355, 35, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-10 15:24:50.462198', b'1', b'1', '2026-02-10 15:25:01.151319', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 3);
INSERT INTO `notifications` VALUES (356, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:18.976866', b'1', b'1', '2026-02-10 16:06:24.346128', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (357, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:18.979368', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (358, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:18.986184', b'1', b'1', '2026-02-19 21:52:54.489015', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (359, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:18.987743', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (360, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:18.991060', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (361, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:18.993050', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (362, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:18.995566', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (363, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:19.002313', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (364, 45, 'DISH', '新菜品【红烧牛肉面】上线啦，快去尝鲜吧！', '2026-02-10 16:06:19.004954', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 12);
INSERT INTO `notifications` VALUES (369, 36, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-10 16:06:58.533667', b'1', b'1', '2026-02-10 16:52:19.698909', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (370, 84, 'ORDER', '订单【ORD1770712791976】支付成功，已为您安排制作。', '2026-02-10 16:39:57.484190', b'1', b'1', '2026-02-10 16:52:19.698909', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (373, 84, 'ORDER', '您的订单【ORD1770712791976】商家已接单，正在为您制作中。', '2026-02-10 16:40:21.819054', b'1', b'1', '2026-02-10 16:52:19.698909', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (374, 84, 'ORDER', '您的订单【ORD1770712791976】已制作完成，请前往取餐口取餐。', '2026-02-10 16:40:22.650527', b'1', b'1', '2026-02-10 16:52:19.698909', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (377, 84, 'ORDER', '您的订单【ORD1770712791976】已完成，感谢您的光临！', '2026-02-10 16:40:25.557941', b'1', b'1', '2026-02-10 16:52:19.698909', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (384, 35, 'REVIEW', '食堂回复了您的评价：感谢好评，祝您生活愉快', '2026-02-10 17:26:11.839975', b'1', b'1', '2026-02-19 21:52:54.489015', 'COMMENT_REPLY', '您的评价有新回复', 'COMMENT', 3);
INSERT INTO `notifications` VALUES (385, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.225930', b'1', b'1', '2026-02-10 21:10:12.165895', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (386, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.230669', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (387, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.234043', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (388, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.235668', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (389, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.239995', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (390, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.241670', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (391, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.244943', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (392, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.247727', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (393, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.249716', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (394, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.253420', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (395, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:28:23.254446', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (396, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.962170', b'1', b'1', '2026-02-10 21:10:12.165895', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (397, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.971499', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (398, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.973447', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (399, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.975338', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (400, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.979499', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (401, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.984910', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (402, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.986706', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (403, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.989193', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (404, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.992797', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (405, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.998334', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (406, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:39:27.999977', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (407, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.641494', b'1', b'1', '2026-02-10 21:10:12.165895', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (408, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.643020', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (409, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.644070', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (410, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.644602', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (411, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.645633', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (412, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.647186', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (413, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.648561', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (414, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.650108', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (415, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.650108', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (416, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.651646', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (417, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:40:07.653267', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (418, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.213294', b'1', b'1', '2026-02-10 21:10:12.165895', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (419, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.218116', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (420, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.219701', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (421, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.222755', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (422, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.223978', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (423, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.225540', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (424, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.227113', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (425, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.229198', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (426, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.233291', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (427, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.234806', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (428, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:49:22.237146', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (429, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.237135', b'1', b'1', '2026-02-10 21:10:12.165895', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (430, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.240039', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (431, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.241554', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (432, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.243434', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (433, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.246010', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (434, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.247488', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (435, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.249615', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (436, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.251711', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (437, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.253268', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (438, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.254465', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (439, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 20:58:13.257118', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (440, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.364450', b'1', b'1', '2026-02-10 21:10:12.165895', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (441, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.366788', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (442, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.366788', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (443, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.368326', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (444, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.369849', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (445, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.369849', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (446, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.371372', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (447, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.372101', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (448, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.372944', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (449, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.374460', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (450, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 20:58:36.374460', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (452, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.242758', b'1', b'1', '2026-02-10 21:12:59.495038', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (453, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.245234', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (454, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.246702', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (455, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.254029', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (456, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.255620', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (457, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.257398', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (458, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.258768', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (459, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.260321', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (460, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.261867', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (461, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.263479', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (462, 7, 'PROMOTION', '促销【情人节促销】已开始（2026-02-10 00:00 - 2026-03-21 00:00），快来看看吧！', '2026-02-10 21:10:34.265355', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (463, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.154712', b'1', b'1', '2026-02-10 21:12:59.495038', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (464, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.156427', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (465, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.158034', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (466, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.160702', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (467, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.162303', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (468, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.164359', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (469, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.165429', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (470, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.167079', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (471, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.168698', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (472, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.170442', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (473, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-10 21:10:47.172040', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (474, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.793047', b'1', b'1', '2026-02-10 21:12:59.495038', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (475, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.794575', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (476, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.794575', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (477, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.796093', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (478, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.796093', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (479, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.797612', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (480, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.798416', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (481, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.799423', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (482, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.799423', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (483, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.801119', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (484, 8, 'PROMOTION', '促销【大套餐】已开始（2026-02-09 00:00 - 2027-03-18 00:00），快来看看吧！', '2026-02-10 21:12:41.801639', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (494, 94, 'ORDER', '订单【ORD1770813010947】支付成功，已为您安排制作。', '2026-02-11 20:30:13.737614', b'1', b'1', '2026-02-11 21:21:34.130850', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (495, 94, 'ORDER', '您的订单【ORD1770813010947】商家已接单，正在为您制作中。', '2026-02-11 20:30:20.357112', b'1', b'1', '2026-02-11 21:21:34.130850', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (496, 94, 'ORDER', '您的订单【ORD1770813010947】已制作完成，请前往取餐口取餐。', '2026-02-11 20:30:21.364409', b'1', b'1', '2026-02-11 21:21:34.130850', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (497, 94, 'ORDER', '您的订单【ORD1770813010947】已完成，感谢您的光临！', '2026-02-11 20:30:22.605155', b'1', b'1', '2026-02-11 21:21:34.130850', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (502, 37, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-02-11 22:44:24.565490', b'1', b'1', '2026-02-12 16:31:08.771623', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (507, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.119862', b'1', b'1', '2026-02-12 16:31:08.771623', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (508, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.121384', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (509, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.121384', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (510, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.124319', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (511, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.124319', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (512, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.125905', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (513, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.128562', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (514, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.130119', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (515, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.131717', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (516, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.133246', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (517, 9, 'PROMOTION', '促销【213】已开始（2026-02-12 00:00 - 2026-03-26 00:00），快来看看吧！', '2026-02-12 16:10:37.133246', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (518, 101, 'ORDER', '订单【ORD1770883855561】支付成功，已为您安排制作。', '2026-02-12 16:10:57.131100', b'1', b'1', '2026-02-12 16:31:08.771623', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (519, 101, 'ORDER', '您的订单【ORD1770883855561】商家已接单，正在为您制作中。', '2026-02-12 16:11:06.421531', b'1', b'1', '2026-02-12 16:31:08.771623', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (520, 101, 'ORDER', '您的订单【ORD1770883855561】已制作完成，请前往取餐口取餐。', '2026-02-12 16:11:07.387876', b'1', b'1', '2026-02-12 16:31:08.771623', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (521, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.861401', b'1', b'1', '2026-02-12 16:31:08.771623', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (522, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.863153', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (523, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.863661', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (524, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.865239', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (525, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.866793', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (526, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.866793', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (527, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.868728', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (528, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.869500', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (529, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.870651', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (530, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.871153', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (531, 10, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-19 00:00），快来看看吧！', '2026-02-12 16:11:43.872688', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (532, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.187446', b'1', b'1', '2026-02-12 16:31:08.771623', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (533, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.188538', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (534, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.190088', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (535, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.191795', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (536, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.194765', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (537, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.194765', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (538, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.196911', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (539, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.197913', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (540, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.201370', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (541, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.203798', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (542, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:11:48.210727', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (543, 101, 'ORDER', '您的订单【ORD1770883855561】已完成，感谢您的光临！', '2026-02-12 16:25:12.198767', b'1', b'1', '2026-02-12 16:31:08.771623', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (544, 38, 'REVIEW', '感谢您的评价！您获得了 30 积分奖励。', '2026-02-12 16:25:24.811205', b'1', b'1', '2026-02-12 16:31:08.771623', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (545, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.290263', b'1', b'1', '2026-02-12 16:31:08.771623', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (546, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.294961', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (547, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.296489', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (548, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.298094', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (549, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.300779', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (550, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.304056', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (551, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.306825', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (552, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.310627', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (553, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.312478', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (554, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.314112', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (555, 11, 'PROMOTION', '促销【满20减5】已开始（2026-02-12 00:00 - 2026-03-27 00:00），快来看看吧！', '2026-02-12 16:28:54.317477', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (557, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.896870', b'1', b'1', '2026-02-12 16:31:08.771623', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (558, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.899910', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (559, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.900912', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (560, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.906497', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (561, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.908027', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (562, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.908027', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (563, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.909582', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (564, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.909582', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (565, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.912265', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (566, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.913419', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (567, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-12 16:30:59.913921', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (568, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.208998', b'1', b'1', '2026-02-18 21:48:34.071751', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (569, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.214935', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (570, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.216993', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (571, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.218010', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (572, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.220797', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (573, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.222345', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (574, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.224151', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (575, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.226811', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (576, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.229284', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (577, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.231765', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (578, 12, 'PROMOTION', '促销【促销】已开始（2026-02-18 00:00 - 2026-03-28 00:00），快来看看吧！', '2026-02-18 21:47:57.233416', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (583, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.841807', b'1', b'1', '2026-02-19 20:55:09.498092', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (584, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.843883', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (585, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.845513', b'1', b'1', '2026-02-19 21:52:54.489015', 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (586, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.845513', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (587, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.847064', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (588, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.848657', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (589, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.850245', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (590, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.850245', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (591, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.851797', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (592, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.853309', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (593, 5, 'PROMOTION', '促销【春节促销】已开始（2026-02-02 00:00 - 2026-02-25 00:00），快来看看吧！', '2026-02-18 21:48:43.853309', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (602, 7, 'REWARD_EXCHANGE', '您的奖品【5元代价券】已送达，请注意查收。', '2026-02-19 20:09:11.808116', b'1', b'1', '2026-02-19 20:55:09.498092', 'REWARD_DELIVERY', '奖品已送达', 'REWARD', 1);
INSERT INTO `notifications` VALUES (608, 110, 'ORDER', '订单【ORD1771506340848】支付成功，已为您安排制作。', '2026-02-19 21:05:42.937802', b'1', b'1', '2026-02-19 21:13:40.595352', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (609, 110, 'ORDER', '您的订单【ORD1771506340848】商家已接单，正在为您制作中。', '2026-02-19 21:05:48.314320', b'1', b'1', '2026-02-19 21:13:40.595352', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (612, 110, 'ORDER', '您的订单【ORD1771506340848】已制作完成，请前往取餐口取餐。', '2026-02-19 21:05:51.447672', b'1', b'1', '2026-02-19 21:13:40.595352', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (613, 110, 'ORDER', '您的订单【ORD1771506340848】已完成，感谢您的光临！', '2026-02-19 21:05:53.829300', b'1', b'1', '2026-02-19 21:13:40.595352', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (614, 57, 'ORDER', '您的订单【ORD1770182084045】商家已接单，正在为您制作中。', '2026-02-19 21:06:16.072079', b'1', b'1', '2026-02-19 21:13:40.595352', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (615, 57, 'ORDER', '您的订单【ORD1770182084045】已制作完成，请前往取餐口取餐。', '2026-02-19 21:06:17.019216', b'1', b'1', '2026-02-19 21:13:40.595352', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (616, 57, 'ORDER', '您的订单【ORD1770182084045】已完成，感谢您的光临！', '2026-02-19 21:06:17.998285', b'1', b'1', '2026-02-19 21:13:40.595352', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (618, 112, 'ORDER', '订单【ORD1771676077714】支付成功，已为您安排制作。', '2026-02-21 20:14:40.116973', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (619, 111, 'ORDER', '订单【ORD1771676072010】支付成功，已为您安排制作。', '2026-02-21 20:14:41.709639', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (620, 111, 'ORDER', '您的订单【ORD1771676072010】商家已接单，正在为您制作中。', '2026-02-21 20:14:45.804441', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (621, 112, 'ORDER', '您的订单【ORD1771676077714】商家已接单，正在为您制作中。', '2026-02-21 20:14:46.972386', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (622, 111, 'ORDER', '您的订单【ORD1771676072010】已制作完成，请前往取餐口取餐。', '2026-02-21 20:14:47.968644', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (623, 112, 'ORDER', '您的订单【ORD1771676077714】已制作完成，请前往取餐口取餐。', '2026-02-21 20:14:48.821958', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (624, 111, 'ORDER', '您的订单【ORD1771676072010】已完成，感谢您的光临！', '2026-02-21 20:14:51.166684', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (625, 112, 'ORDER', '您的订单【ORD1771676077714】已完成，感谢您的光临！', '2026-02-21 20:14:52.113472', b'1', b'1', '2026-03-02 11:41:30.915586', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (626, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.151212', b'1', b'1', '2026-03-02 11:41:30.915586', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (627, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.155341', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (628, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.156900', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (629, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.158434', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (630, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.162494', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (631, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.164074', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (632, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.165658', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (633, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.169179', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (634, 8, 'DISH', '菜品【清蒸鱼】已重新上架，快去看看吧！', '2026-03-02 11:40:49.171240', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 12);
INSERT INTO `notifications` VALUES (635, 15, 'ORDER', '您的订单【ORD176889886297914】已制作完成，请前往取餐口取餐。', '2026-03-05 10:12:49.096172', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (636, 113, 'ORDER', '订单【ORD1772677145008】支付成功，已为您安排制作。', '2026-03-05 10:19:12.278810', b'1', b'1', '2026-03-05 10:20:12.549894', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (637, 115, 'ORDER', '订单【ORD1773211712181】支付成功，已为您安排制作。', '2026-03-11 14:48:38.168417', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (638, 116, 'ORDER', '订单【ORD1773212422853】支付成功，已为您安排制作。', '2026-03-11 15:00:36.893496', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (639, 115, 'ORDER', '您的订单【ORD1773211712181】商家已接单，正在为您制作中。', '2026-03-11 15:01:02.732740', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (640, 116, 'ORDER', '您的订单【ORD1773212422853】商家已接单，正在为您制作中。', '2026-03-11 15:01:04.366227', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (641, 115, 'ORDER', '您的订单【ORD1773211712181】已制作完成，请前往取餐口取餐。', '2026-03-11 15:01:06.485533', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (642, 116, 'ORDER', '您的订单【ORD1773212422853】已制作完成，请前往取餐口取餐。', '2026-03-11 15:01:08.186653', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (643, 116, 'ORDER', '您的订单【ORD1773212422853】已完成，感谢您的光临！', '2026-03-11 15:01:13.336630', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (644, 115, 'ORDER', '您的订单【ORD1773211712181】已完成，感谢您的光临！', '2026-03-11 15:01:14.757638', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 25);
INSERT INTO `notifications` VALUES (645, 39, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-03-11 15:01:23.392338', b'0', b'0', NULL, 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 25);
INSERT INTO `notifications` VALUES (646, 40, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-03-11 15:01:30.032080', b'0', b'0', NULL, 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 25);
INSERT INTO `notifications` VALUES (651, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.462403', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (652, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.464989', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (653, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.466651', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (654, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.468215', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (655, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.469848', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (656, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.473560', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (657, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.474566', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (658, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.476151', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (659, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.477765', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (660, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.480663', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (661, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.481672', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (662, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.484588', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 25);
INSERT INTO `notifications` VALUES (663, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.486219', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 26);
INSERT INTO `notifications` VALUES (664, 13, 'PROMOTION', '促销【套餐】已开始（2026-03-23 00:00 - 2026-04-30 00:00），快来看看吧！', '2026-03-23 10:54:55.487846', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始', 'PROMOTION', 27);
INSERT INTO `notifications` VALUES (665, 114, 'ORDER', '订单【ORD1773203087685】支付成功，已为您安排制作。', '2026-03-23 10:55:49.146674', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (666, 119, 'ORDER', '订单【ORD1774237451243】支付成功，已为您安排制作。', '2026-03-23 11:44:13.648110', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (667, 119, 'ORDER', '您的订单【ORD1774237451243】商家已接单，正在为您制作中。', '2026-03-23 11:44:27.878329', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (668, 119, 'ORDER', '您的订单【ORD1774237451243】已制作完成，请前往取餐口取餐。', '2026-03-23 11:44:30.437385', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (669, 119, 'ORDER', '您的订单【ORD1774237451243】已完成，感谢您的光临！', '2026-03-23 11:50:28.402624', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (670, 120, 'ORDER', '订单【ORD1774237867698】支付成功，已为您安排制作。', '2026-03-23 11:51:09.644515', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (671, 120, 'ORDER', '您的订单【ORD1774237867698】商家已接单，正在为您制作中。', '2026-03-23 11:51:16.556574', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (672, 120, 'ORDER', '您的订单【ORD1774237867698】已制作完成，请前往取餐口取餐。', '2026-03-23 11:51:17.560593', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (673, 120, 'ORDER', '您的订单【ORD1774237867698】已完成，感谢您的光临！', '2026-03-23 11:51:18.977782', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);

-- ----------------------------
-- Table structure for order_items
-- ----------------------------
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单明细ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `dish_id` bigint NOT NULL COMMENT '菜品ID',
  `order_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '数量',
  `unit_price` decimal(38, 2) NOT NULL,
  `subtotal` decimal(38, 2) NOT NULL,
  `total_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '总金额',
  `pickup_time` datetime NULL DEFAULT NULL COMMENT '取餐时间',
  `window_id` bigint NULL DEFAULT NULL,
  `window_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `window_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `pickup_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `payment_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `payment_transaction_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `payment_time` datetime NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_gift` bit(1) NULL DEFAULT NULL,
  `combo_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_items_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_order_items_dish_id`(`dish_id` ASC) USING BTREE,
  INDEX `FK406a8m2k9pylvb0rynoxx4o43`(`combo_id` ASC) USING BTREE,
  CONSTRAINT `FK406a8m2k9pylvb0rynoxx4o43` FOREIGN KEY (`combo_id`) REFERENCES `combos` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_items_dish` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 168 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (3, 3, 14, '2026-01-20 16:47:42', 1, 16.00, 16.00, NULL, NULL, 26, '粤菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886281420', '2025-12-27 02:55:43', '2025-12-27 02:50:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (4, 3, 26, '2026-01-20 16:47:42', 2, 22.00, 44.00, NULL, NULL, 16, '盖浇饭窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886281421', '2025-12-27 02:55:43', '2025-12-27 02:50:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (5, 3, 5, '2026-01-20 16:47:42', 3, 5.00, 15.00, NULL, NULL, 15, '特色菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886281422', '2025-12-27 02:55:43', '2025-12-27 02:50:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (6, 4, 32, '2026-01-20 16:47:42', 2, 52.00, 104.00, NULL, NULL, 18, '苏菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886283430', '2026-01-14 00:11:43', '2026-01-14 00:06:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (8, 5, 29, '2026-01-20 16:47:42', 2, 45.00, 90.00, NULL, NULL, 14, '湘菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886284840', '2026-01-12 22:45:43', '2026-01-12 22:40:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (9, 5, 19, '2026-01-20 16:47:42', 1, 48.00, 48.00, NULL, NULL, 10, '鲁菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886284841', '2026-01-12 22:45:43', '2026-01-12 22:40:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (10, 5, 16, '2026-01-20 16:47:42', 1, 32.00, 32.00, NULL, NULL, 8, '粤菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886284842', '2026-01-12 22:45:43', '2026-01-12 22:40:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (14, 7, 31, '2026-01-20 16:47:42', 1, 68.00, 68.00, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2025-12-27 05:49:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (15, 7, 18, '2026-01-20 16:47:42', 1, 42.00, 42.00, NULL, NULL, 25, '特色菜窗口', '三楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2025-12-27 05:49:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (18, 9, 8, '2026-01-20 16:47:42', 2, 20.00, 40.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886290781', '2025-12-22 05:07:43', '2025-12-22 05:02:43', '2026-02-07 14:18:32', NULL, NULL);
INSERT INTO `order_items` VALUES (19, 9, 13, '2026-01-20 16:47:42', 3, 38.00, 114.00, NULL, NULL, 17, '粤菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX176889886290782', '2025-12-22 05:07:43', '2025-12-22 05:02:43', '2026-02-07 14:18:32', NULL, NULL);
INSERT INTO `order_items` VALUES (24, 13, 16, '2026-01-20 16:47:42', 2, 32.00, 64.00, NULL, NULL, 8, '粤菜窗口', '三楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-01-03 23:46:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (25, 14, 29, '2026-01-20 16:47:42', 1, 45.00, 45.00, NULL, NULL, 14, '湘菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898862965130', '2026-01-07 03:12:43', '2026-01-07 03:07:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (26, 14, 1, '2026-01-20 16:47:42', 2, 12.00, 24.00, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898862965131', '2026-01-07 03:12:43', '2026-01-07 03:07:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (27, 15, 5, '2026-01-20 16:47:42', 1, 5.00, 5.00, NULL, NULL, 15, '特色菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898862979140', '2026-01-20 00:39:43', '2026-01-20 00:34:43', '2026-03-05 10:12:49', NULL, NULL);
INSERT INTO `order_items` VALUES (30, 17, 24, '2026-01-20 16:47:43', 3, 68.00, 204.00, NULL, NULL, 27, '苏菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898862998161', '2026-01-10 18:21:43', '2026-01-10 18:16:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (31, 17, 23, '2026-01-20 16:47:43', 2, 10.00, 20.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898862998162', '2026-01-10 18:21:43', '2026-01-10 18:16:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (34, 19, 2, '2026-01-20 16:47:43', 1, 10.00, 10.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1769497034556', '2026-01-27 14:57:15', '2025-12-24 05:22:43', '2026-02-03 22:41:42', NULL, NULL);
INSERT INTO `order_items` VALUES (35, 19, 25, '2026-01-20 16:47:43', 2, 58.00, 116.00, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1769497034556', '2026-01-27 14:57:15', '2025-12-24 05:22:43', '2026-02-03 22:41:42', NULL, NULL);
INSERT INTO `order_items` VALUES (36, 20, 21, '2026-01-20 16:47:43', 2, 15.00, 30.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863029190', '2025-12-24 23:53:43', '2025-12-24 23:48:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (37, 20, 30, '2026-01-20 16:47:43', 1, 48.00, 48.00, NULL, NULL, 22, '浙菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863029191', '2025-12-24 23:53:43', '2025-12-24 23:48:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (38, 20, 1, '2026-01-20 16:47:43', 2, 12.00, 24.00, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863029192', '2025-12-24 23:53:43', '2025-12-24 23:48:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (39, 21, 24, '2026-01-20 16:47:43', 3, 68.00, 204.00, NULL, NULL, 27, '苏菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863042200', '2026-01-16 14:25:43', '2026-01-16 14:20:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (40, 21, 23, '2026-01-20 16:47:43', 3, 10.00, 30.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863042201', '2026-01-16 14:25:43', '2026-01-16 14:20:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (51, 27, 2, '2026-01-20 16:47:43', 3, 10.00, 30.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863125260', '2025-12-31 14:19:43', '2025-12-31 14:14:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (52, 27, 9, '2026-01-20 16:47:43', 1, 16.00, 16.00, NULL, NULL, 23, '清真窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863125261', '2025-12-31 14:19:43', '2025-12-31 14:14:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (54, 29, 6, '2026-01-20 16:47:43', 2, 3.00, 6.00, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863146280', '2025-12-31 10:18:43', '2025-12-31 10:13:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (55, 29, 28, '2026-01-20 16:47:43', 1, 32.00, 32.00, NULL, NULL, 5, '湘菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863146281', '2025-12-31 10:18:43', '2025-12-31 10:13:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (56, 29, 27, '2026-01-20 16:47:43', 3, 58.00, 174.00, NULL, NULL, 24, '湘菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863146282', '2025-12-31 10:18:43', '2025-12-31 10:13:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (63, 32, 1, '2026-01-24 20:40:59', 1, 12.00, 12.00, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-01-24 20:40:59', '2026-01-24 20:40:59', NULL, NULL);
INSERT INTO `order_items` VALUES (64, 32, 30, '2026-01-24 20:40:59', 1, 48.00, 48.00, NULL, NULL, 22, '浙菜窗口', '一楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-01-24 20:40:59', '2026-01-24 20:40:59', NULL, NULL);
INSERT INTO `order_items` VALUES (72, 49, 2, '2026-02-02 20:20:09', 1, 10.00, 10.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770034858000', '2026-02-02 20:20:58', '2026-02-02 20:20:09', '2026-02-02 20:21:09', NULL, NULL);
INSERT INTO `order_items` VALUES (73, 50, 1, '2026-02-02 20:20:19', 1, 12.00, 12.00, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770034859850', '2026-02-02 20:21:00', '2026-02-02 20:20:20', '2026-02-02 20:21:10', NULL, NULL);
INSERT INTO `order_items` VALUES (74, 51, 2, '2026-02-03 11:35:46', 1, 10.00, 10.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-02-03 11:35:46', '2026-02-03 11:35:46', NULL, NULL);
INSERT INTO `order_items` VALUES (75, 52, 4, '2026-02-03 11:43:20', 1, 5.60, 5.60, NULL, NULL, 6, '特色菜窗口', '二楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-02-03 11:43:20', '2026-02-03 11:43:20', NULL, NULL);
INSERT INTO `order_items` VALUES (76, 53, 31, '2026-02-03 12:43:04', 1, 54.40, 54.40, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770093787702', '2026-02-03 12:43:08', '2026-02-03 12:43:04', '2026-02-03 12:43:08', NULL, NULL);
INSERT INTO `order_items` VALUES (77, 54, 7, '2026-02-03 17:57:15', 1, 7.00, 7.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770129742942', '2026-02-03 22:42:23', '2026-02-03 17:57:16', '2026-02-04 10:52:03', NULL, NULL);
INSERT INTO `order_items` VALUES (78, 55, 1, '2026-02-03 21:57:26', 1, 8.40, 8.40, NULL, '2026-02-03 23:57:42', 1, '上海菜窗口', '一楼东侧', 'RESERVATION', NULL, 'WECHAT', 'TX1770127050781', '2026-02-03 21:57:31', '2026-02-03 21:57:26', '2026-02-03 21:57:47', NULL, NULL);
INSERT INTO `order_items` VALUES (79, 55, 2, '2026-02-03 21:57:26', 1, 7.00, 7.00, NULL, '2026-02-03 23:57:42', 12, '川菜窗口', '一楼西侧', 'RESERVATION', NULL, 'WECHAT', 'TX1770127050781', '2026-02-03 21:57:31', '2026-02-03 21:57:26', '2026-02-03 21:57:47', NULL, NULL);
INSERT INTO `order_items` VALUES (82, 57, 31, '2026-02-04 13:14:44', 1, 47.60, 47.60, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770192002094', '2026-02-04 16:00:02', '2026-02-04 13:14:44', '2026-02-19 21:06:17', NULL, NULL);
INSERT INTO `order_items` VALUES (83, 58, 34, '2026-02-05 14:51:05', 1, 12.60, 12.60, NULL, NULL, 7, '甜品窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770274266551', '2026-02-05 14:51:07', '2026-02-05 14:51:05', '2026-02-05 14:51:15', NULL, NULL);
INSERT INTO `order_items` VALUES (89, 63, 1, '2026-02-06 21:09:46', 2, 8.40, 16.80, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770383399142', '2026-02-06 21:09:59', '2026-02-06 21:09:47', '2026-02-06 21:10:09', NULL, NULL);
INSERT INTO `order_items` VALUES (90, 64, 2, '2026-02-06 21:10:23', 1, 7.00, 7.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770383424415', '2026-02-06 21:10:24', '2026-02-06 21:10:24', '2026-02-06 21:10:32', NULL, NULL);
INSERT INTO `order_items` VALUES (91, 65, 5, '2026-02-06 21:10:54', 1, 3.50, 3.50, NULL, NULL, 15, '特色菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770383455108', '2026-02-06 21:10:55', '2026-02-06 21:10:54', '2026-02-06 21:11:03', NULL, NULL);
INSERT INTO `order_items` VALUES (92, 66, 7, '2026-02-06 21:18:57', 1, 7.00, 7.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770383938782', '2026-02-06 21:18:59', '2026-02-06 21:18:57', '2026-02-06 21:19:11', NULL, NULL);
INSERT INTO `order_items` VALUES (94, 68, 6, '2026-02-06 21:55:45', 1, 2.10, 2.10, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770386146765', '2026-02-06 21:55:47', '2026-02-06 21:55:46', '2026-02-06 21:55:55', NULL, NULL);
INSERT INTO `order_items` VALUES (95, 69, 1, '2026-02-06 22:23:12', 3, 8.40, 25.20, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770387794189', '2026-02-06 22:23:14', '2026-02-06 22:23:13', '2026-02-06 22:23:21', NULL, NULL);
INSERT INTO `order_items` VALUES (96, 70, 2, '2026-02-06 22:23:41', 42, 7.00, 294.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770387823433', '2026-02-06 22:23:43', '2026-02-06 22:23:42', '2026-02-06 22:23:52', NULL, NULL);
INSERT INTO `order_items` VALUES (103, 75, 25, '2026-02-07 23:24:09', 50, 40.60, 2030.00, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770477850469', '2026-02-07 23:24:10', '2026-02-07 23:24:09', '2026-02-07 23:24:17', NULL, NULL);
INSERT INTO `order_items` VALUES (104, 76, 9, '2026-02-08 00:14:28', 1, 11.20, 11.20, NULL, NULL, 23, '清真窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770480869927', '2026-02-08 00:14:30', '2026-02-08 00:14:29', '2026-02-09 15:36:38', NULL, NULL);
INSERT INTO `order_items` VALUES (105, 77, 31, '2026-02-09 15:35:07', 1, 47.60, 47.60, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770622508500', '2026-02-09 15:35:09', '2026-02-09 15:35:07', '2026-02-09 15:36:39', NULL, NULL);
INSERT INTO `order_items` VALUES (112, 81, 10, '2026-02-09 17:45:20', 1, 1.40, 1.40, NULL, NULL, 3, '早餐窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770630321309', '2026-02-09 17:45:21', '2026-02-09 17:45:20', '2026-02-09 17:45:33', b'0', NULL);
INSERT INTO `order_items` VALUES (113, 81, 11, '2026-02-09 17:45:20', 1, 0.00, 0.00, NULL, NULL, 13, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770630321309', '2026-02-09 17:45:21', '2026-02-09 17:45:20', '2026-02-09 17:45:33', b'1', NULL);
INSERT INTO `order_items` VALUES (114, 82, 3, '2026-02-10 14:22:51', 1, 5.60, 5.60, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770704572601', '2026-02-10 14:22:53', '2026-02-10 14:22:51', '2026-02-10 14:23:03', b'0', NULL);
INSERT INTO `order_items` VALUES (115, 82, 4, '2026-02-10 14:22:51', 1, 4.90, 4.90, NULL, NULL, 6, '特色菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770704572601', '2026-02-10 14:22:53', '2026-02-10 14:22:51', '2026-02-10 14:23:03', b'0', NULL);
INSERT INTO `order_items` VALUES (117, 84, 3, '2026-02-10 16:39:52', 2, 5.60, 11.20, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770712797444', '2026-02-10 16:39:57', '2026-02-10 16:39:52', '2026-02-10 16:40:23', b'0', NULL);
INSERT INTO `order_items` VALUES (118, 84, 2, '2026-02-10 16:39:52', 2, 7.00, 14.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770712797444', '2026-02-10 16:39:57', '2026-02-10 16:39:52', '2026-02-10 16:40:23', b'0', NULL);
INSERT INTO `order_items` VALUES (130, 94, 7, '2026-02-11 20:30:10', 1, 7.00, 7.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'ALIPAY', 'TX1770813013695', '2026-02-11 20:30:14', '2026-02-11 20:30:11', '2026-02-11 20:30:21', b'0', NULL);
INSERT INTO `order_items` VALUES (131, 95, 3, '2026-02-11 21:27:50', 1, 5.32, 5.32, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-02-11 21:27:51', '2026-02-11 21:27:51', b'0', NULL);
INSERT INTO `order_items` VALUES (137, 101, 7, '2026-02-12 16:10:55', 1, 8.00, 8.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770883857106', '2026-02-12 16:10:57', '2026-02-12 16:10:56', '2026-02-12 16:11:07', b'0', NULL);
INSERT INTO `order_items` VALUES (146, 110, 23, '2026-02-19 21:05:40', 1, 7.00, 7.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771506342867', '2026-02-19 21:05:43', '2026-02-19 21:05:41', '2026-02-19 21:05:51', b'0', NULL);
INSERT INTO `order_items` VALUES (147, 110, 27, '2026-02-19 21:05:40', 1, 40.60, 40.60, NULL, NULL, 24, '湘菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771506342867', '2026-02-19 21:05:43', '2026-02-19 21:05:41', '2026-02-19 21:05:51', b'0', NULL);
INSERT INTO `order_items` VALUES (148, 110, 28, '2026-02-19 21:05:40', 1, 22.40, 22.40, NULL, NULL, 5, '湘菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771506342867', '2026-02-19 21:05:43', '2026-02-19 21:05:41', '2026-02-19 21:05:51', b'0', NULL);
INSERT INTO `order_items` VALUES (149, 110, 14, '2026-02-19 21:05:40', 1, 11.20, 11.20, NULL, NULL, 26, '粤菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771506342867', '2026-02-19 21:05:43', '2026-02-19 21:05:41', '2026-02-19 21:05:51', b'0', NULL);
INSERT INTO `order_items` VALUES (150, 110, 7, '2026-02-19 21:05:40', 1, 7.00, 7.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771506342867', '2026-02-19 21:05:43', '2026-02-19 21:05:41', '2026-02-19 21:05:51', b'0', NULL);
INSERT INTO `order_items` VALUES (151, 111, 2, '2026-02-21 20:14:32', 1, 6.65, 6.65, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771676081682', '2026-02-21 20:14:42', '2026-02-21 20:14:32', '2026-02-21 20:14:48', b'0', NULL);
INSERT INTO `order_items` VALUES (152, 111, 6, '2026-02-21 20:14:32', 1, 2.10, 2.10, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771676081682', '2026-02-21 20:14:42', '2026-02-21 20:14:32', '2026-02-21 20:14:48', b'0', NULL);
INSERT INTO `order_items` VALUES (153, 112, 2, '2026-02-21 20:14:37', 1, 6.65, 6.65, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771676080082', '2026-02-21 20:14:40', '2026-02-21 20:14:38', '2026-02-21 20:14:49', b'0', NULL);
INSERT INTO `order_items` VALUES (154, 112, 6, '2026-02-21 20:14:37', 1, 2.10, 2.10, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771676080082', '2026-02-21 20:14:40', '2026-02-21 20:14:38', '2026-02-21 20:14:49', b'0', NULL);
INSERT INTO `order_items` VALUES (155, 113, 3, '2026-03-05 10:19:05', 1, 8.00, 8.00, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'ALIPAY', 'TX1772677152236', '2026-03-05 10:19:12', '2026-03-05 10:19:05', '2026-03-05 10:19:12', b'0', NULL);
INSERT INTO `order_items` VALUES (156, 114, 2, '2026-03-11 12:24:47', 1, 10.00, 10.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1774234548810', '2026-03-23 10:55:49', '2026-03-11 12:24:48', '2026-03-23 10:55:49', b'0', NULL);
INSERT INTO `order_items` VALUES (157, 115, 34, '2026-03-11 14:48:32', 1, 18.00, 18.00, NULL, NULL, 7, '甜品窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1773211718042', '2026-03-11 14:48:38', '2026-03-11 14:48:32', '2026-03-11 15:01:06', b'0', NULL);
INSERT INTO `order_items` VALUES (158, 116, 2, '2026-03-11 15:00:22', 1, 10.00, 10.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1773212436793', '2026-03-11 15:00:37', '2026-03-11 15:00:23', '2026-03-11 15:01:08', b'0', NULL);
INSERT INTO `order_items` VALUES (162, 119, 3, '2026-03-23 11:44:11', 1, 5.52, 5.52, NULL, NULL, 20, '川菜窗口', '一楼南侧', NULL, NULL, 'WECHAT', 'TX1774237453290', '2026-03-23 11:44:13', '2026-03-23 11:44:11', '2026-03-23 11:44:30', b'0', 8);
INSERT INTO `order_items` VALUES (163, 119, 5, '2026-03-23 11:44:11', 1, 3.45, 3.45, NULL, NULL, 15, '特色菜窗口', '二楼西侧', NULL, NULL, 'WECHAT', 'TX1774237453290', '2026-03-23 11:44:13', '2026-03-23 11:44:11', '2026-03-23 11:44:30', b'0', 8);
INSERT INTO `order_items` VALUES (164, 119, 14, '2026-03-23 11:44:11', 1, 11.03, 11.03, NULL, NULL, 26, '粤菜窗口', '二楼南侧', NULL, NULL, 'WECHAT', 'TX1774237453290', '2026-03-23 11:44:13', '2026-03-23 11:44:11', '2026-03-23 11:44:30', b'0', 8);
INSERT INTO `order_items` VALUES (165, 120, 3, '2026-03-23 11:51:07', 1, 5.52, 5.52, NULL, NULL, 20, '川菜窗口', '一楼南侧', NULL, NULL, 'WECHAT', 'TX1774237869568', '2026-03-23 11:51:10', '2026-03-23 11:51:08', '2026-03-23 11:51:18', b'0', 8);
INSERT INTO `order_items` VALUES (166, 120, 5, '2026-03-23 11:51:07', 1, 3.45, 3.45, NULL, NULL, 15, '特色菜窗口', '二楼西侧', NULL, NULL, 'WECHAT', 'TX1774237869568', '2026-03-23 11:51:10', '2026-03-23 11:51:08', '2026-03-23 11:51:18', b'0', 8);
INSERT INTO `order_items` VALUES (167, 120, 14, '2026-03-23 11:51:07', 1, 11.03, 11.03, NULL, NULL, 26, '粤菜窗口', '二楼南侧', NULL, NULL, 'WECHAT', 'TX1774237869568', '2026-03-23 11:51:10', '2026-03-23 11:51:08', '2026-03-23 11:51:18', b'0', 8);

-- ----------------------------
-- Table structure for order_status_history
-- ----------------------------
DROP TABLE IF EXISTS `order_status_history`;
CREATE TABLE `order_status_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `change_time` datetime(6) NOT NULL,
  `from_status` enum('CANCELLED','COMPLETED','PAID','PENDING','PREPARING','READY') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `to_status` enum('CANCELLED','COMPLETED','PAID','PENDING','PREPARING','READY') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `order_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKnmcbg3mmbt8wfva97ra40nmp3`(`order_id` ASC) USING BTREE,
  CONSTRAINT `FKnmcbg3mmbt8wfva97ra40nmp3` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_status_history
-- ----------------------------
INSERT INTO `order_status_history` VALUES (4, '2026-01-27 14:57:14.600654', 'PENDING', '支付成功，交易号: TX1769497034556', 'PAID', 19);
INSERT INTO `order_status_history` VALUES (6, '2026-02-02 20:20:58.037997', 'PENDING', '支付成功，交易号: TX1770034858000', 'PAID', 49);
INSERT INTO `order_status_history` VALUES (7, '2026-02-02 20:20:59.873334', 'PENDING', '支付成功，交易号: TX1770034859850', 'PAID', 50);
INSERT INTO `order_status_history` VALUES (8, '2026-02-03 12:43:07.748079', 'PENDING', '支付成功，交易号: TX1770093787702', 'PAID', 53);
INSERT INTO `order_status_history` VALUES (9, '2026-02-03 21:57:30.811434', 'PENDING', '支付成功，交易号: TX1770127050781', 'PAID', 55);
INSERT INTO `order_status_history` VALUES (10, '2026-02-03 22:42:22.975978', 'PENDING', '支付成功，交易号: TX1770129742942', 'PAID', 54);
INSERT INTO `order_status_history` VALUES (12, '2026-02-04 16:00:02.123879', 'PENDING', '支付成功，交易号: TX1770192002094', 'PAID', 57);
INSERT INTO `order_status_history` VALUES (13, '2026-02-05 14:51:06.596786', 'PENDING', '支付成功，交易号: TX1770274266551', 'PAID', 58);
INSERT INTO `order_status_history` VALUES (18, '2026-02-06 21:09:59.178068', 'PENDING', '支付成功，交易号: TX1770383399142', 'PAID', 63);
INSERT INTO `order_status_history` VALUES (19, '2026-02-06 21:10:24.438111', 'PENDING', '支付成功，交易号: TX1770383424415', 'PAID', 64);
INSERT INTO `order_status_history` VALUES (20, '2026-02-06 21:10:55.130741', 'PENDING', '支付成功，交易号: TX1770383455108', 'PAID', 65);
INSERT INTO `order_status_history` VALUES (21, '2026-02-06 21:18:58.829184', 'PENDING', '支付成功，交易号: TX1770383938782', 'PAID', 66);
INSERT INTO `order_status_history` VALUES (23, '2026-02-06 21:55:46.788030', 'PENDING', '支付成功，交易号: TX1770386146765', 'PAID', 68);
INSERT INTO `order_status_history` VALUES (24, '2026-02-06 22:23:14.215744', 'PENDING', '支付成功，交易号: TX1770387794189', 'PAID', 69);
INSERT INTO `order_status_history` VALUES (25, '2026-02-06 22:23:43.456122', 'PENDING', '支付成功，交易号: TX1770387823433', 'PAID', 70);
INSERT INTO `order_status_history` VALUES (30, '2026-02-07 23:24:10.498778', 'PENDING', '支付成功，交易号: TX1770477850469', 'PAID', 75);
INSERT INTO `order_status_history` VALUES (31, '2026-02-08 00:14:29.953987', 'PENDING', '支付成功，交易号: TX1770480869927', 'PAID', 76);
INSERT INTO `order_status_history` VALUES (32, '2026-02-09 15:35:08.525317', 'PENDING', '支付成功，交易号: TX1770622508500', 'PAID', 77);
INSERT INTO `order_status_history` VALUES (34, '2026-02-09 17:45:21.345778', 'PENDING', '支付成功，交易号: TX1770630321309', 'PAID', 81);
INSERT INTO `order_status_history` VALUES (35, '2026-02-10 14:22:52.660907', 'PENDING', '支付成功，交易号: TX1770704572601', 'PAID', 82);
INSERT INTO `order_status_history` VALUES (37, '2026-02-10 16:39:57.475189', 'PENDING', '支付成功，交易号: TX1770712797444', 'PAID', 84);
INSERT INTO `order_status_history` VALUES (46, '2026-02-11 20:30:13.728144', 'PENDING', '支付成功，交易号: TX1770813013695', 'PAID', 94);
INSERT INTO `order_status_history` VALUES (49, '2026-02-12 16:10:57.126612', 'PENDING', '支付成功，交易号: TX1770883857106', 'PAID', 101);
INSERT INTO `order_status_history` VALUES (55, '2026-02-19 21:05:42.929169', 'PENDING', '支付成功，交易号: TX1771506342867', 'PAID', 110);
INSERT INTO `order_status_history` VALUES (56, '2026-02-21 20:14:40.102520', 'PENDING', '支付成功，交易号: TX1771676080082', 'PAID', 112);
INSERT INTO `order_status_history` VALUES (57, '2026-02-21 20:14:41.706356', 'PENDING', '支付成功，交易号: TX1771676081682', 'PAID', 111);
INSERT INTO `order_status_history` VALUES (58, '2026-03-05 10:19:12.264080', 'PENDING', '支付成功，交易号: TX1772677152236', 'PAID', 113);
INSERT INTO `order_status_history` VALUES (59, '2026-03-11 14:48:38.135838', 'PENDING', '支付成功，交易号: TX1773211718042', 'PAID', 115);
INSERT INTO `order_status_history` VALUES (60, '2026-03-11 15:00:36.872734', 'PENDING', '支付成功，交易号: TX1773212436793', 'PAID', 116);
INSERT INTO `order_status_history` VALUES (63, '2026-03-23 10:55:49.139658', 'PENDING', '支付成功，交易号: TX1774234548810', 'PAID', 114);
INSERT INTO `order_status_history` VALUES (64, '2026-03-23 11:44:13.641575', 'PENDING', '支付成功，交易号: TX1774237453290', 'PAID', 119);
INSERT INTO `order_status_history` VALUES (65, '2026-03-23 11:51:09.637903', 'PENDING', '支付成功，交易号: TX1774237869568', 'PAID', 120);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` enum('PENDING','PAID','PREPARING','READY','COMPLETED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'PENDING' COMMENT '订单状态',
  `total_amount` decimal(38, 2) NOT NULL,
  `goods_amount` decimal(38, 2) NULL DEFAULT NULL,
  `payable_amount` decimal(38, 2) NULL DEFAULT NULL,
  `voucher_deduction` decimal(38, 2) NULL DEFAULT NULL,
  `voucher_exchange_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_orders_order_number`(`order_number` ASC) USING BTREE,
  INDEX `idx_orders_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_orders_status_create_time`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 121 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (3, 4, 'ORD17688988628142', 'PREPARING', 75.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (4, 1, 'ORD17688988628343', 'COMPLETED', 124.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (5, 3, 'ORD17688988628484', 'COMPLETED', 170.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (7, 1, 'ORD17688988628836', 'PENDING', 110.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (9, 4, 'ORD17688988629078', 'COMPLETED', 194.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (13, 1, 'ORD176889886295612', 'PENDING', 64.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (14, 3, 'ORD176889886296513', 'PAID', 69.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (15, 4, 'ORD176889886297914', 'READY', 5.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (17, 3, 'ORD176889886299816', 'COMPLETED', 268.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (19, 1, 'ORD176889886302018', 'COMPLETED', 126.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (20, 3, 'ORD176889886302919', 'PAID', 102.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (21, 4, 'ORD176889886304220', 'PREPARING', 234.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (26, 3, 'ORD176889886311625', 'PAID', 60.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (27, 4, 'ORD176889886312526', 'PREPARING', 46.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (29, 3, 'ORD176889886314528', 'COMPLETED', 212.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (32, 1, 'ORD1769258458952', 'PENDING', 60.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (49, 1, 'ORD1770034809016', 'COMPLETED', 10.00, 10.00, 10.00, 0.00, NULL);
INSERT INTO `orders` VALUES (50, 1, 'ORD1770034819614', 'COMPLETED', 12.00, 12.00, 12.00, 0.00, NULL);
INSERT INTO `orders` VALUES (51, 1, 'ORD1770089746419', 'PENDING', 10.00, 10.00, 10.00, 0.00, NULL);
INSERT INTO `orders` VALUES (52, 1, 'ORD1770090200154', 'PENDING', 5.60, 5.60, 5.60, 0.00, NULL);
INSERT INTO `orders` VALUES (53, 1, 'ORD1770093784013', 'PAID', 54.40, 54.40, 54.40, 0.00, NULL);
INSERT INTO `orders` VALUES (54, 3, 'ORD1770112635550', 'COMPLETED', 7.00, 7.00, 7.00, 0.00, NULL);
INSERT INTO `orders` VALUES (55, 1, 'ORD1770127046202', 'COMPLETED', 15.40, 15.40, 15.40, 0.00, NULL);
INSERT INTO `orders` VALUES (57, 1, 'ORD1770182084045', 'COMPLETED', 47.60, 47.60, 47.60, 0.00, NULL);
INSERT INTO `orders` VALUES (58, 1, 'ORD1770274265242', 'COMPLETED', 12.60, 12.60, 12.60, 0.00, NULL);
INSERT INTO `orders` VALUES (63, 1, 'ORD1770383386870', 'COMPLETED', 16.80, 16.80, 16.80, 0.00, NULL);
INSERT INTO `orders` VALUES (64, 1, 'ORD1770383423562', 'COMPLETED', 7.00, 7.00, 7.00, 0.00, NULL);
INSERT INTO `orders` VALUES (65, 1, 'ORD1770383454300', 'COMPLETED', 3.50, 3.50, 3.50, 0.00, NULL);
INSERT INTO `orders` VALUES (66, 1, 'ORD1770383937106', 'COMPLETED', 7.00, 7.00, 7.00, 0.00, NULL);
INSERT INTO `orders` VALUES (68, 1, 'ORD1770386145560', 'COMPLETED', 2.10, 2.10, 2.10, 0.00, NULL);
INSERT INTO `orders` VALUES (69, 1, 'ORD1770387792782', 'COMPLETED', 25.20, 25.20, 25.20, 0.00, NULL);
INSERT INTO `orders` VALUES (70, 1, 'ORD1770387821949', 'COMPLETED', 294.00, 294.00, 294.00, 0.00, NULL);
INSERT INTO `orders` VALUES (75, 1, 'ORD1770477849290', 'COMPLETED', 2030.00, 2030.00, 2030.00, 0.00, NULL);
INSERT INTO `orders` VALUES (76, 1, 'ORD1770480868519', 'COMPLETED', 1.20, 11.20, 1.20, 10.00, 4);
INSERT INTO `orders` VALUES (77, 1, 'ORD1770622507104', 'COMPLETED', 47.60, 47.60, 47.60, 0.00, NULL);
INSERT INTO `orders` VALUES (81, 1, 'ORD1770630320184', 'COMPLETED', 1.40, 1.40, 1.40, 0.00, NULL);
INSERT INTO `orders` VALUES (82, 1, 'ORD1770704570988', 'COMPLETED', 10.50, 10.50, 10.50, 0.00, NULL);
INSERT INTO `orders` VALUES (84, 1, 'ORD1770712791976', 'COMPLETED', 25.20, 25.20, 25.20, 0.00, NULL);
INSERT INTO `orders` VALUES (94, 1, 'ORD1770813010947', 'COMPLETED', 7.00, 7.00, 7.00, 0.00, NULL);
INSERT INTO `orders` VALUES (95, 1, 'ORD1770816470528', 'PENDING', 5.32, 5.32, 5.32, 0.00, NULL);
INSERT INTO `orders` VALUES (101, 1, 'ORD1770883855561', 'COMPLETED', 8.00, 8.00, 8.00, 0.00, NULL);
INSERT INTO `orders` VALUES (110, 1, 'ORD1771506340848', 'COMPLETED', 88.20, 88.20, 88.20, 0.00, NULL);
INSERT INTO `orders` VALUES (111, 1, 'ORD1771676072010', 'COMPLETED', 8.75, 8.75, 8.75, 0.00, NULL);
INSERT INTO `orders` VALUES (112, 1, 'ORD1771676077714', 'COMPLETED', 8.75, 8.75, 8.75, 0.00, NULL);
INSERT INTO `orders` VALUES (113, 1, 'ORD1772677145008', 'PAID', 8.00, 8.00, 8.00, 0.00, NULL);
INSERT INTO `orders` VALUES (114, 3, 'ORD1773203087685', 'PAID', 10.00, 10.00, 10.00, 0.00, NULL);
INSERT INTO `orders` VALUES (115, 25, 'ORD1773211712181', 'COMPLETED', 18.00, 18.00, 18.00, 0.00, NULL);
INSERT INTO `orders` VALUES (116, 25, 'ORD1773212422853', 'COMPLETED', 10.00, 10.00, 10.00, 0.00, NULL);
INSERT INTO `orders` VALUES (119, 1, 'ORD1774237451243', 'COMPLETED', 20.00, 20.00, 20.00, 0.00, NULL);
INSERT INTO `orders` VALUES (120, 1, 'ORD1774237867698', 'COMPLETED', 20.00, 20.00, 20.00, 0.00, NULL);

-- ----------------------------
-- Table structure for point_logs
-- ----------------------------
DROP TABLE IF EXISTS `point_logs`;
CREATE TABLE `point_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `points` int NOT NULL,
  `source` enum('EXCHANGE','ORDER','OTHER','REVIEW_REWARD') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` enum('EARN','SPEND') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK15n4gica2qwsebf21gp07vw9n`(`user_id` ASC) USING BTREE,
  CONSTRAINT `FK15n4gica2qwsebf21gp07vw9n` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 52 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of point_logs
-- ----------------------------
INSERT INTO `point_logs` VALUES (1, '2026-01-16 13:05:40.720372', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (2, '2026-01-16 14:26:10.024946', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (3, '2026-01-16 14:28:31.172137', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (4, '2026-01-16 15:32:25.945354', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (5, '2026-01-21 12:59:01.596782', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (6, '2026-01-21 12:59:01.679191', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (7, '2026-01-21 12:59:01.733669', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (8, '2026-01-22 20:52:18.069170', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (9, '2026-01-22 20:52:58.806820', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (10, '2026-01-22 20:53:04.153232', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (11, '2026-01-22 20:53:04.203903', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (12, '2026-01-22 20:53:05.947063', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (13, '2026-01-23 21:40:41.052317', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (14, '2026-01-23 21:40:41.079063', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (15, '2026-01-24 20:56:02.453412', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (16, '2026-01-24 20:56:02.485244', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (17, '2026-01-27 21:05:53.153651', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (21, '2026-01-31 22:29:51.224073', '兑换奖励: 10元代金券', -100, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (22, '2026-02-02 22:09:06.303203', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (23, '2026-02-02 22:09:06.318656', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (24, '2026-02-02 22:39:17.116513', '兑换奖励: 数字周边礼包', -200, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (25, '2026-02-03 22:11:32.895723', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (26, '2026-02-04 11:31:19.034833', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 7);
INSERT INTO `point_logs` VALUES (27, '2026-02-04 16:00:36.322616', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (28, '2026-02-04 16:13:33.716865', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (29, '2026-02-04 16:35:45.574074', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (30, '2026-02-04 17:01:47.066423', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (31, '2026-02-06 22:24:11.228880', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (32, '2026-02-07 15:12:52.852392', '兑换奖励: 百科全书', -200, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (33, '2026-02-07 20:40:24.109395', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (34, '2026-02-07 20:40:24.125840', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (35, '2026-02-07 22:57:58.803180', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (36, '2026-02-07 22:57:58.823001', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (37, '2026-02-07 23:44:33.358811', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (38, '2026-02-08 00:13:56.942915', '兑换奖励: 10元代金券', -100, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (39, '2026-02-08 00:14:12.860630', '兑换奖励: 数字周边礼包', -200, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (40, '2026-02-10 14:24:04.285707', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (41, '2026-02-10 14:24:04.304646', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (42, '2026-02-10 14:24:34.351786', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (43, '2026-02-10 15:24:50.458778', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (44, '2026-02-10 16:06:58.529569', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (45, '2026-02-11 10:30:43.212078', '兑换奖励: 10元代金券', -100, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (46, '2026-02-11 22:44:24.557365', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (47, '2026-02-12 16:25:24.797255', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (48, '2026-02-12 16:25:24.809829', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (49, '2026-02-19 20:08:11.258225', '兑换奖励: 5元代价券', -30, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (50, '2026-03-11 15:01:23.388058', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 25);
INSERT INTO `point_logs` VALUES (51, '2026-03-11 15:01:30.030465', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 25);

-- ----------------------------
-- Table structure for promotion_dish_categories
-- ----------------------------
DROP TABLE IF EXISTS `promotion_dish_categories`;
CREATE TABLE `promotion_dish_categories`  (
  `promotion_id` bigint NOT NULL,
  `dish_category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `FKb7qgdqe44o8lwpa6xg8jt48lg`(`promotion_id` ASC) USING BTREE,
  CONSTRAINT `FKb7qgdqe44o8lwpa6xg8jt48lg` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of promotion_dish_categories
-- ----------------------------

-- ----------------------------
-- Table structure for promotion_dishes
-- ----------------------------
DROP TABLE IF EXISTS `promotion_dishes`;
CREATE TABLE `promotion_dishes`  (
  `promotion_id` bigint NOT NULL,
  `dish_id` bigint NOT NULL,
  INDEX `FKgxct2kdh96jj5tc08usfl6le5`(`dish_id` ASC) USING BTREE,
  INDEX `FK3d2fovk3unnxaci12lg7lgulc`(`promotion_id` ASC) USING BTREE,
  CONSTRAINT `FK3d2fovk3unnxaci12lg7lgulc` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKgxct2kdh96jj5tc08usfl6le5` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of promotion_dishes
-- ----------------------------

-- ----------------------------
-- Table structure for promotions
-- ----------------------------
DROP TABLE IF EXISTS `promotions`;
CREATE TABLE `promotions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `discount_value` double NULL DEFAULT NULL,
  `end_time` datetime(6) NOT NULL,
  `full_amount` double NULL DEFAULT NULL,
  `gift_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `is_hot` bit(1) NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `order_count` int NOT NULL,
  `reduce_amount` double NULL DEFAULT NULL,
  `start_time` datetime(6) NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `target_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `total_discount` double NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of promotions
-- ----------------------------
INSERT INTO `promotions` VALUES (13, '', 0.8, '2026-04-30 00:00:00.000000', NULL, NULL, b'0', '套餐', 0, NULL, '2026-03-23 00:00:00.000000', 'active', 'all', 0, 'combo');

-- ----------------------------
-- Table structure for review_items
-- ----------------------------
DROP TABLE IF EXISTS `review_items`;
CREATE TABLE `review_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `rating` int NOT NULL,
  `dish_id` bigint NOT NULL,
  `review_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKdj9gdi79qay5i0trrocgg3df8`(`dish_id` ASC) USING BTREE,
  INDEX `FKo682u4fwor9s8kdqqc4w09kj6`(`review_id` ASC) USING BTREE,
  CONSTRAINT `FKdj9gdi79qay5i0trrocgg3df8` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKo682u4fwor9s8kdqqc4w09kj6` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of review_items
-- ----------------------------
INSERT INTO `review_items` VALUES (33, '2026-01-27 21:05:53.024488', 4, 6, 17);
INSERT INTO `review_items` VALUES (34, '2026-01-27 21:05:53.026994', 5, 28, 17);
INSERT INTO `review_items` VALUES (35, '2026-01-27 21:05:53.029727', 4, 27, 17);
INSERT INTO `review_items` VALUES (37, '2026-02-03 22:11:32.779543', 5, 1, 23);
INSERT INTO `review_items` VALUES (38, '2026-02-03 22:11:32.782082', 5, 2, 23);
INSERT INTO `review_items` VALUES (57, '2026-02-10 15:24:50.363359', 5, 7, 35);
INSERT INTO `review_items` VALUES (62, '2026-02-12 16:25:24.725663', 3, 7, 38);
INSERT INTO `review_items` VALUES (63, '2026-03-11 15:01:23.331756', 5, 2, 39);
INSERT INTO `review_items` VALUES (64, '2026-03-11 15:01:29.993085', 5, 34, 40);

-- ----------------------------
-- Table structure for review_quick_tags
-- ----------------------------
DROP TABLE IF EXISTS `review_quick_tags`;
CREATE TABLE `review_quick_tags`  (
  `review_id` bigint NOT NULL,
  `quick_tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `quick_tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `idx_review_id`(`review_id` ASC) USING BTREE,
  CONSTRAINT `review_quick_tags_ibfk_1` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评价快捷标签表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of review_quick_tags
-- ----------------------------
INSERT INTO `review_quick_tags` VALUES (17, '价格实惠', NULL);
INSERT INTO `review_quick_tags` VALUES (17, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (17, '服务好', NULL);
INSERT INTO `review_quick_tags` VALUES (23, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (23, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (23, '食材新鲜', NULL);
INSERT INTO `review_quick_tags` VALUES (35, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (35, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (38, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (38, '食材新鲜', NULL);
INSERT INTO `review_quick_tags` VALUES (39, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (40, '香气扑鼻', NULL);

-- ----------------------------
-- Table structure for review_reward_records
-- ----------------------------
DROP TABLE IF EXISTS `review_reward_records`;
CREATE TABLE `review_reward_records`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `points_awarded` int NOT NULL,
  `review_id` bigint NOT NULL,
  `rule_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKfr430i8sm7ixdjsawoxdnw92u`(`review_id` ASC) USING BTREE,
  INDEX `FKg0fcthqhkm6tum6vwr2x4hsg4`(`rule_id` ASC) USING BTREE,
  INDEX `FKq72f5lw2qwkohgtfg57t5co7k`(`user_id` ASC) USING BTREE,
  CONSTRAINT `FKfr430i8sm7ixdjsawoxdnw92u` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKg0fcthqhkm6tum6vwr2x4hsg4` FOREIGN KEY (`rule_id`) REFERENCES `review_reward_rules` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKq72f5lw2qwkohgtfg57t5co7k` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of review_reward_records
-- ----------------------------
INSERT INTO `review_reward_records` VALUES (1, '2026-01-16 13:05:40.683730', 10, 95, 1, 1);
INSERT INTO `review_reward_records` VALUES (2, '2026-01-16 14:26:09.997851', 10, 96, 1, 1);
INSERT INTO `review_reward_records` VALUES (3, '2026-01-16 14:28:31.167476', 10, 97, 1, 1);
INSERT INTO `review_reward_records` VALUES (4, '2026-01-16 15:32:25.923719', 10, 64, 1, 1);
INSERT INTO `review_reward_records` VALUES (5, '2026-01-21 12:59:01.578671', 10, 1, 1, 1);
INSERT INTO `review_reward_records` VALUES (6, '2026-01-21 12:59:01.671942', 10, 2, 1, 1);
INSERT INTO `review_reward_records` VALUES (9, '2026-01-22 20:52:58.803397', 10, 5, 1, 1);
INSERT INTO `review_reward_records` VALUES (16, '2026-01-24 20:56:02.480821', 10, 17, 1, 3);
INSERT INTO `review_reward_records` VALUES (28, '2026-01-27 21:05:53.117421', 20, 17, 2, 3);
INSERT INTO `review_reward_records` VALUES (31, '2026-02-03 22:11:32.870198', 10, 23, 1, 1);
INSERT INTO `review_reward_records` VALUES (46, '2026-02-10 15:24:50.444576', 10, 35, 1, 3);
INSERT INTO `review_reward_records` VALUES (49, '2026-02-12 16:25:24.788346', 10, 38, 1, 1);
INSERT INTO `review_reward_records` VALUES (50, '2026-02-12 16:25:24.805230', 20, 38, 2, 1);
INSERT INTO `review_reward_records` VALUES (51, '2026-03-11 15:01:23.381245', 10, 39, 1, 25);
INSERT INTO `review_reward_records` VALUES (52, '2026-03-11 15:01:30.026554', 10, 40, 1, 25);

-- ----------------------------
-- Table structure for review_reward_rules
-- ----------------------------
DROP TABLE IF EXISTS `review_reward_rules`;
CREATE TABLE `review_reward_rules`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `daily_limit` int NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `end_time` datetime(6) NULL DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `multiplier` double NULL DEFAULT NULL,
  `points` int NOT NULL,
  `rule_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `rule_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `start_time` datetime(6) NULL DEFAULT NULL,
  `update_time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `UKgo00mitt8qp23yj3ke1j1sl34`(`rule_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of review_reward_rules
-- ----------------------------
INSERT INTO `review_reward_rules` VALUES (1, '2026-01-14 14:04:37.099422', 5, '完成评价即可获得', NULL, b'1', 1, 10, 'BASIC_REVIEW', '基础评价奖励', NULL, '2026-01-14 14:04:37.099422');
INSERT INTO `review_reward_rules` VALUES (2, '2026-01-14 14:04:37.115385', 5, '包含图片的评价额外奖励', NULL, b'1', 1, 20, 'IMAGE_REVIEW', '图文评价奖励', NULL, '2026-01-14 14:04:37.115385');
INSERT INTO `review_reward_rules` VALUES (3, '2026-01-14 14:04:37.124854', 3, '字数超过50字的评价额外奖励', NULL, b'1', 1, 30, 'LONG_TEXT', '长评奖励', NULL, '2026-01-14 14:04:37.124854');
INSERT INTO `review_reward_rules` VALUES (4, '2026-01-14 14:04:37.134951', 1, '综合质量评分超过80分的评价', NULL, b'1', 1, 50, 'HIGH_QUALITY', '优质评价奖励', NULL, '2026-01-14 14:04:37.134951');

-- ----------------------------
-- Table structure for reviews
-- ----------------------------
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `taste_rating` int NULL DEFAULT NULL COMMENT '口味评分 1-5',
  `portion_rating` int NULL DEFAULT NULL COMMENT '分量评分 1-5',
  `price_rating` int NULL DEFAULT NULL COMMENT '价格评分 1-5',
  `hygiene_rating` int NULL DEFAULT NULL COMMENT '卫生评分 1-5',
  `overall_rating` double NULL DEFAULT NULL COMMENT '综合评分',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价图片',
  `canteen_reply` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `reply_time` datetime NULL DEFAULT NULL COMMENT '回复时间',
  `create_time` datetime NULL DEFAULT NULL,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `is_rewarded` bit(1) NOT NULL,
  `quality_score` int NULL DEFAULT NULL,
  `order_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_reviews_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `fk_reviews_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKqwgq1lxgahsxdspnwqfac6sv6` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评价表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reviews
-- ----------------------------
INSERT INTO `reviews` VALUES (17, 3, 4, 4, 4, 5, 4.25, '小炒肉很好吃，鱼头很辣很香', '[\"62c27337-0742-4ec2-988f-e6fc217ca886_16-凯影125.png\"]', '感谢您的评价，祝您生活愉快', '2026-01-27 21:06:44', '2026-01-27 21:05:53', 'NORMAL', b'1', 52, 29);
INSERT INTO `reviews` VALUES (23, 1, 5, 5, 5, 5, 5, '', '[]', '感谢您的评价', '2026-02-03 22:11:50', '2026-02-03 22:11:33', 'NORMAL', b'1', 0, 55);
INSERT INTO `reviews` VALUES (35, 3, 5, 5, 5, 5, 5, '', '[]', '感谢好评，祝您生活愉快', '2026-02-10 17:26:12', '2026-02-10 15:24:50', 'NORMAL', b'1', 0, 54);
INSERT INTO `reviews` VALUES (38, 1, 5, 3, 3, 2, 3.25, '', '[\"/uploads/a587376a-1ab9-4dfa-a02d-7dd46c27b44d_屏幕截图 2025-11-18 102357.png\"]', NULL, NULL, '2026-02-12 16:25:25', 'NORMAL', b'1', 0, 101);
INSERT INTO `reviews` VALUES (39, 25, 5, 5, 5, 5, 5, '好', '[]', NULL, NULL, '2026-03-11 15:01:23', 'NORMAL', b'1', 20, 116);
INSERT INTO `reviews` VALUES (40, 25, 5, 5, 5, 5, 5, '啊啊啊', '[]', NULL, NULL, '2026-03-11 15:01:30', 'NORMAL', b'1', 20, 115);

-- ----------------------------
-- Table structure for reward_categories
-- ----------------------------
DROP TABLE IF EXISTS `reward_categories`;
CREATE TABLE `reward_categories`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sort_order` int NULL DEFAULT 0,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ENABLED',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_reward_categories_name`(`name` ASC) USING BTREE,
  INDEX `idx_reward_categories_status_sort`(`status` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reward_categories
-- ----------------------------
INSERT INTO `reward_categories` VALUES (1, '代金券', 1, 'ENABLED', '2026-01-31 22:01:50', '2026-01-31 22:01:50');
INSERT INTO `reward_categories` VALUES (2, '实物奖品', 2, 'ENABLED', '2026-01-31 22:01:50', '2026-01-31 22:01:50');
INSERT INTO `reward_categories` VALUES (3, '数字周边', 3, 'ENABLED', '2026-01-31 22:01:50', '2026-01-31 22:01:50');

-- ----------------------------
-- Table structure for reward_exchanges
-- ----------------------------
DROP TABLE IF EXISTS `reward_exchanges`;
CREATE TABLE `reward_exchanges`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `reward_id` bigint NOT NULL,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING',
  `request_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `points_used` int NULL DEFAULT NULL,
  `face_value_snapshot` decimal(38, 2) NULL DEFAULT NULL,
  `conditions_snapshot` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `used` tinyint(1) NULL DEFAULT 0,
  `used_time` datetime NULL DEFAULT NULL,
  `used_order_id` bigint NULL DEFAULT NULL,
  `deduction_amount` decimal(38, 2) NULL DEFAULT NULL,
  `delivery_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING',
  `delivery_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `receiver_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `receiver_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `error_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `operator_id` bigint NULL DEFAULT NULL,
  `exchange_time` datetime NULL DEFAULT NULL,
  `complete_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_reward_exchanges_request_id`(`request_id` ASC) USING BTREE,
  INDEX `idx_reward_exchanges_user_time`(`user_id` ASC, `exchange_time` ASC) USING BTREE,
  INDEX `idx_reward_exchanges_status_time`(`status` ASC, `exchange_time` ASC) USING BTREE,
  INDEX `idx_reward_exchanges_request_id`(`request_id` ASC) USING BTREE,
  INDEX `fk_reward_exchanges_reward`(`reward_id` ASC) USING BTREE,
  CONSTRAINT `fk_reward_exchanges_reward` FOREIGN KEY (`reward_id`) REFERENCES `rewards` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_reward_exchanges_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reward_exchanges
-- ----------------------------
INSERT INTO `reward_exchanges` VALUES (1, 1, 1, 'COMPLETED', '920e3a13-e977-42ff-a405-0e5cdf84fb0e', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 1, '2026-01-31 22:30:06', 38, 10.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-31 22:29:51', '2026-01-31 22:29:51', '2026-01-31 22:29:51');
INSERT INTO `reward_exchanges` VALUES (2, 1, 3, 'COMPLETED', '2d01cbef-1726-49bf-a847-e32419a9147e', 200, NULL, NULL, 0, NULL, NULL, NULL, 'SHIPPED', '顺丰快递发货', '杨翔宇', '17817171348', '东南大学成贤学院', NULL, NULL, NULL, '2026-02-02 22:39:17', '2026-02-02 22:39:36', '2026-02-07 15:19:24');
INSERT INTO `reward_exchanges` VALUES (3, 1, 4, 'COMPLETED', 'e9db4e29-075e-46b8-a2f7-678bd4af015f', 200, NULL, '', 0, NULL, NULL, NULL, 'DELIVERED', '', '杨翔宇', '17728997857', '东南大学成贤学院', NULL, NULL, NULL, '2026-02-07 15:12:53', '2026-02-07 15:19:12', '2026-02-07 15:19:12');
INSERT INTO `reward_exchanges` VALUES (4, 1, 1, 'COMPLETED', '7d148f39-f67f-416d-9992-aceeb7892516', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 1, '2026-02-08 00:14:29', 76, 10.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-08 00:13:57', '2026-02-08 00:13:57', '2026-02-08 00:13:57');
INSERT INTO `reward_exchanges` VALUES (5, 1, 3, 'COMPLETED', '917272ea-acd5-41e5-9357-794cc7d76fff', 200, NULL, NULL, 0, NULL, NULL, NULL, 'DELIVERED', '', '杨翔宇', '17817171348', '东南大学成贤学院', NULL, NULL, NULL, '2026-02-08 00:14:13', '2026-02-08 00:15:09', '2026-02-08 00:15:09');
INSERT INTO `reward_exchanges` VALUES (6, 1, 1, 'COMPLETED', '7cd83478-4096-4868-80ff-e8f246dd4467', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 1, '2026-02-11 10:31:02', 91, 7.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-11 10:30:43', '2026-02-11 10:30:43', '2026-02-11 10:30:43');
INSERT INTO `reward_exchanges` VALUES (7, 1, 5, 'COMPLETED', '4287fb84-aff2-4ec7-9577-45f15bf0d6b9', 30, 5.00, '', 1, '2026-02-19 20:09:37', 108, 5.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-19 20:08:11', '2026-02-19 20:09:12', '2026-02-19 20:09:12');

-- ----------------------------
-- Table structure for rewards
-- ----------------------------
DROP TABLE IF EXISTS `rewards`;
CREATE TABLE `rewards`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `points_required` int NOT NULL,
  `stock` int NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `category_id` bigint NULL DEFAULT NULL,
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'VOUCHER',
  `face_value` decimal(38, 2) NULL DEFAULT NULL,
  `min_order_amount` decimal(38, 2) NULL DEFAULT NULL,
  `valid_from` datetime NULL DEFAULT NULL,
  `valid_to` datetime NULL DEFAULT NULL,
  `daily_limit` int NULL DEFAULT NULL,
  `per_user_limit` int NULL DEFAULT NULL,
  `exchange_enabled` tinyint(1) NULL DEFAULT 1,
  `attributes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `version` int NULL DEFAULT NULL,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'AVAILABLE',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_rewards_status_points`(`status` ASC, `points_required` ASC) USING BTREE,
  INDEX `idx_rewards_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_rewards_type`(`type` ASC) USING BTREE,
  CONSTRAINT `fk_rewards_category` FOREIGN KEY (`category_id`) REFERENCES `reward_categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rewards
-- ----------------------------
INSERT INTO `rewards` VALUES (1, '10元代金券', '全场通用抵扣10元', 100, 47, 'https://images.unsplash.com/photo-1556742502-ec7c0e9f34b1?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80', 1, 'VOUCHER', 10.00, 0.00, '2026-01-30 22:01:50', '2026-03-02 22:01:50', 1, 3, 1, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 0, 'AVAILABLE', '2026-01-31 22:01:50', '2026-01-31 22:01:50');
INSERT INTO `rewards` VALUES (2, '食堂实物奖品', '食堂联名马克杯', 300, 5, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80', 2, 'OTHER', NULL, NULL, NULL, NULL, 0, 1, 1, NULL, 0, 'AVAILABLE', '2026-01-31 22:01:50', '2026-01-31 22:01:50');
INSERT INTO `rewards` VALUES (3, '数字周边礼包', '校园数字周边兑换码', 200, 18, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', 3, 'OTHER', NULL, NULL, NULL, NULL, 0, 2, 1, NULL, 0, 'AVAILABLE', '2026-01-31 22:01:50', '2026-01-31 22:01:50');
INSERT INTO `rewards` VALUES (4, '百科全书', '', 200, 29, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80', 2, 'OTHER', NULL, NULL, '2026-02-07 00:00:00', '2027-03-20 00:00:00', 5, 2, 1, '', 1, 'DELETED', '2026-02-07 15:12:11', '2026-02-08 00:12:48');
INSERT INTO `rewards` VALUES (5, '5元代价券', '5元代金券', 30, 29, NULL, 1, 'VOUCHER', 5.00, 5.00, '2026-02-18 00:00:00', '2026-03-28 00:00:00', 30, 5, 1, '', 3, 'DELETED', '2026-02-18 20:37:29', '2026-02-19 20:24:04');
INSERT INTO `rewards` VALUES (6, '3元代金券', '', 10, 30, NULL, 1, 'VOUCHER', 3.00, 3.00, '2026-02-20 00:00:00', '2026-03-18 00:00:00', 6, 4, 1, '', 1, 'DELETED', '2026-02-20 21:14:21', '2026-02-20 21:14:37');

-- ----------------------------
-- Table structure for system_announcements
-- ----------------------------
DROP TABLE IF EXISTS `system_announcements`;
CREATE TABLE `system_announcements`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `content` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `creator_id` bigint NULL DEFAULT NULL,
  `end_time` datetime(6) NULL DEFAULT NULL,
  `priority` int NOT NULL,
  `start_time` datetime(6) NULL DEFAULT NULL,
  `status` enum('DRAFT','OFFLINE','PUBLISHED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `target_canteen_id` bigint NULL DEFAULT NULL,
  `target_role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `target_window_id` bigint NULL DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_announcements
-- ----------------------------
INSERT INTO `system_announcements` VALUES (3, '完成评价即可获得10积分！\n包含图片的评价额外奖励20积分！\n字数超过50字的评价额外奖励30积分！\n综合质量评分超过80分的评价50积分！\n积分可在兑换中心兑换精美奖品', '2026-02-04 11:51:44.540787', NULL, NULL, 0, '2026-02-04 11:51:44.540787', 'PUBLISHED', NULL, NULL, NULL, '积分奖励机制', '2026-02-04 11:51:44.540787');

-- ----------------------------
-- Table structure for user_preferences
-- ----------------------------
DROP TABLE IF EXISTS `user_preferences`;
CREATE TABLE `user_preferences`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `dietary_restrictions` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `spiciness_level` int NULL DEFAULT NULL,
  `sweetness_level` int NULL DEFAULT NULL,
  `update_time` datetime(6) NULL DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `UKqy8dkrkc8b34dcgwoq2km43rd`(`user_id` ASC) USING BTREE,
  CONSTRAINT `FKepakpib0qnm82vmaiismkqf88` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_preferences
-- ----------------------------

-- ----------------------------
-- Table structure for user_profile
-- ----------------------------
DROP TABLE IF EXISTS `user_profile`;
CREATE TABLE `user_profile`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键，自增',
  `user_id` bigint NOT NULL COMMENT '用户ID，关联 users.id',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dietary_restrictions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `flavor_preferences` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `allergies` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `is_vegetarian` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否素食',
  `is_halal` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否清真',
  `spice_tolerance` int NULL DEFAULT NULL COMMENT '辣度耐受度(1-5)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_profile_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_user_profile_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户偏好画像表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_profile
-- ----------------------------
INSERT INTO `user_profile` VALUES (1, 1, '2026-01-14 13:20:28', '2026-02-11 10:30:33', '无', '无,辣度:4,川菜,健身餐,重口,甜度:1', NULL, NULL, 0, 0, 4);
INSERT INTO `user_profile` VALUES (2, 3, '2026-01-14 13:20:28', '2026-02-02 11:25:44', '不吃牛肉，不吃海鲜', '辣度:3,不吃牛肉，不吃海鲜,粤菜,清真,甜度:3,家常菜', NULL, NULL, 0, 1, 3);
INSERT INTO `user_profile` VALUES (3, 4, '2026-01-14 13:20:28', '2026-01-14 13:20:28', NULL, '川菜,徽菜,甜度:2,辣度:4,重口,高蛋白', NULL, NULL, 0, 0, 4);
INSERT INTO `user_profile` VALUES (4, 7, '2026-01-14 13:52:08', '2026-01-14 13:52:08', '不吃油腻食物', '川菜,辣度:2,重口,不吃油腻食物,高蛋白,甜度:1', NULL, NULL, 0, 0, 2);
INSERT INTO `user_profile` VALUES (5, 8, '2026-02-02 22:10:31', '2026-02-02 22:10:31', '不吃海鲜', '无麸质,辣度:3,川菜,甜度:2,东北菜,低脂,不吃海鲜', NULL, NULL, 0, 0, 3);
INSERT INTO `user_profile` VALUES (7, 11, '2026-02-02 22:10:51', '2026-02-02 22:10:51', '不吃蒜', '辣度:5,湘菜,不吃蒜,苏菜,甜度:1', NULL, NULL, 0, 0, 5);
INSERT INTO `user_profile` VALUES (8, 5, '2026-02-02 22:11:02', '2026-02-02 22:11:02', '不吃辣', '清淡,不吃辣,辣度:1,高蛋白,甜度:3,苏菜,浙菜', NULL, NULL, 0, 0, 1);
INSERT INTO `user_profile` VALUES (9, 10, '2026-02-02 22:11:12', '2026-02-02 22:11:12', '素食主义', '素食,辣度:4,素食主义,粤菜,东北菜,甜度:1', NULL, NULL, 1, 0, 4);
INSERT INTO `user_profile` VALUES (10, 9, '2026-02-02 22:11:17', '2026-02-02 22:11:17', '不吃香菜，不吃葱', '川菜,辣度:2,不吃香菜，不吃葱,健康,甜度:3', NULL, NULL, 0, 0, 2);
INSERT INTO `user_profile` VALUES (11, 12, '2026-02-02 22:11:22', '2026-02-02 22:11:22', '不吃羊肉', '辣度:3,不吃羊肉,川菜,甜度:5,低脂', NULL, NULL, 0, 0, 3);
INSERT INTO `user_profile` VALUES (13, 2, '2026-02-09 14:19:44', '2026-02-09 15:26:53', '', '素食,辣度:3,川菜,重口,甜度:3,东北菜', NULL, NULL, 1, 0, 3);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `role` enum('STUDENT','WINDOW_MANAGER','ADMIN') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'STUDENT',
  `spiciness_level` int NULL DEFAULT 3 COMMENT '辣度等级 1-5',
  `sweetness_level` int NULL DEFAULT 3 COMMENT '甜度等级 1-5',
  `dietary_restrictions` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `last_review_time` datetime(6) NULL DEFAULT NULL,
  `points` int NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `avatar` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin001', 'admin', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '18813440381', '3198035651@qq.com', 'ADMIN', 4, 1, '无', '2025-11-17 17:16:18', '2026-02-11 10:30:33', '2026-01-02 22:59:25.197476', 70, 'active', '/uploads/47008f05-ad3c-4290-af1a-f56b0a3d7784.png');
INSERT INTO `users` VALUES (2, 'wm001', '窗口管理员', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '18813440381', '3198035651@qq.com', 'WINDOW_MANAGER', 3, 3, '', '2025-11-17 17:16:18', '2026-02-09 15:26:53', NULL, NULL, 'active', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAIAAAD2HxkiAABNoUlEQVR42u29aZQk13Xfee+LPTNrX3tf0CsaO4iFIEBS4CJSpERQFEUtlCVTtMfrHHus42V8NNYZy9YZa+Z4PIvP8Vi2bEq2ZNIkYVIkRYukSGEhgEYDjaWBXtHd1d21ZVXlFnvEe3c+vMzs6u5asnKprGy83+Fpoqsz40VExT/ufffedx/m83loltHR0aa/u7CwoMZV46pxAYA1/U2FQtEWlAgVii6jRKhQdBklQoWiyygRKhRdRolQoegySoQKRZdRIlQouowSoULRZZQIFYouo0SoUHQZJUKFossoESoUXUaJUKHoMkqECkWXUSJUKLqMEqFC0WWUCBWKLqNEqFB0GSSipr/ci/081Lhq3K02rrKECkWXUSJUKLqMEqFC0WWUCBWKLqNEqFB0GSVChaLLKBEqFF1GiVCh6DJKhApFl1EiVCi6jBKhQtFllAgVii6jRKhQdBklQoWiyygRKhRdRolQoegySoQKRZfRu30CbSOKItcPK37oh4kXxlwAIALgTR/L5ZpfPe26btPfVeO2Oi4RAOka5mwz65i5jJV1bNM0mx5l69DbIgzDaH6pdGW+dGXBy1eSUiDCFFJALhCQIa74pcUunawat1WICEhoCCYj24BBR5voN3eNZneND44O9xuG0aUrbRXM5/NNf7lb/TwGBgauzORPnpt+60phupQEKQOm4y2aa755jmJLcutLlUig4DmTdg6Z9+wdvfuObTojTdOaO363nuces4RhFJ25OPPm1crZOd9PddR0AAu1lfWGGz26otdAZKAxl8PpBTg9N/PdV6/tH9UfPDCxb+d4DxnGnhFhkiRvXbj2wtn8xQJxZiLaqAEQASIovb3rISDUjBKHV2bFmzNXDo7OPH5s+76dE01bxc2kN0R4ZXr+B69NnZ7nKbNQW+Z3olKfAgAA5XuYCJEl6JxaFBd+dPm+nfPvv3fP2MhQt89uHba6CMMweuHNi39xplgRFmqG0pxiLfC6FCPMvHA1vTB/+kN3T9x7eLeub91HfeueGQAsLBW//eL5U/OCNAfxuvOpUKwFIgAQETJ9IdW/eiI/lS9/+D0H+3LZbp/ZymxdEV6YmvnGS5enfRM1g4gQUSlQ0TgyWk4AKbOfv5zky29+6rGDE6PD3T6vFdiiFTNvnrv8x89enA5sZBpIBSoUGwelSdSMc0XzP//5mSvT890+oxXYiiI8efriV1+cLoksIgIoF1TREogIRMjYdOh8+dmLU1tPh1tOhG+dn/pvJ2Y9yNR+oBSoaBmpQ8TZyPrys+9cnWm+QKUTbC0RXro6+/Txax5lWj+UQnEDNR3ORdbXf3xhcanY7RO6zhYS4WKh9I0XLxVSp9snorhNqeqQTbnmt148H4Rht0+oylYRYRzH3z1+/opnSA++26ejuE1BJCJk2ptz9MyrF1rZnLONbBURvvzWpddnUmQ6qWSgopMgIhGBbj57vnz6navdPh2ALSLCmfnFH729KDSbVDZC0XnkMxaA8/3Xp13X6/bpbAERcs6feX1qKbHqd0eh6DyEiFNl9uJbU90+ky0gwgtTs69PRzIp3+1zUbx7QCICzXzxQml+odDdU+myCJMkfv7tmQgtgI4viSAAqiEECUG89j8hqj/v7t1QbCbS7SrExomzM909ky7Xjl66tnB+kSManSvOluIiIATUGJo6s0zdNjTL0AydGRojIj/mZS+qBIlQk9J3E0SEmv7q5fJ7Dhe6uOKpmyIkolcvzEdkIrbfDNa0B7ahDfdZO0ZyO0ezk0PZkT67L2NkTAMRyn48la+cny5N5SuCVDuMdx3yhbsU6W++M/cTXRRht/pqjI6OzuUX31lMkJntNYNEJAgMjW0fzhzbM3Ln7qGdI7n+jKlpVd/bj5Kz14qvns+fuVZcrIRJKqD2ElBm8N0GETHdODsXfCKTafF5bvq73bSEb12cXQwAtbaZQSk/29CO7Bx87Oi2o7uG+jLmdV0RFb34xPn5F07PXs5XooQjIgIwpoT37kU+HleKycWr8xPDua6cQ9dEyDl/81IemUFtqtEWRBrikZ2DH7l/17Hdw5Z5w6W5QfzS2fkfvXHtyoLLBTEEjXU/MqzYIkRCf+vSu0+Ei4XS5YUA0GxdgXL6N5SzPvrA7ieObc85N7TZSrl46/LSt09cPnetyAUhgqZMn2I5RMi0szOl94ahbdubP37XRHhtvlAKCFruhSUTCwe3D3z28QMHdwzeNKlbqoTfPTH1zKlpL0oZKs9TsRKIADBXTgtlb9u7SoRTc6UU9RY1ITN7Dx0Y/9z7D44OODf905mrhf/63IXzMyUEZf0U6+DFMLtY2TY+svlDd0eERHRt0QVsaVYmFfjYkclf+MChvswNexKkXDx7avrpFy4W3Iihinkq1kegNlvwuzJ0d0QYhuFCOcIWRCi90IcPTtyqwDBOv3X80n9/5UqUcmUAFY1AAIBs0Y26MnqXRBgllVC0UjRHBEd2Dn7u/QdvUqAXJl999vyP3pwWREwZQEVjIAAglvwkjiPTtDZ59O6E6YMoCRLR9NcF0eiA/fNPHBzpv2Ea7QbJH//o7A/fuKaqzxRN4CcijtPNH7c7ljBKUt5skRgRGRr7xEN7928bWP5zP0q+8uy5Z9+aAVX4omgKLjDlzduGpumSOxonCRfN5ScEwX37Rt97ZHL5D+OUf+OFi8+cuv0UKDdZWPGKZLWrqnhtG2Eq4uRdYwkRsDmpENFg1vzJB3fbywpihKDvn7z6/deu3j4L85EBkUgjHnk8qPDIE0lIaSz7o6BuaobFrIxmZpnpMMNCTZd9bmtrMttVhvTuIk0FF+8aSwhN2StZGfPwoYn9kzc4oq9cyP/JS5cSLno6ElNv9c8jL1y47E+fDRcvJ5UlHvuUxkTi+qJnZMgYagYzbN3O6dkhc2DCGtpuDU7quRHNdADlCmlSu3dsiG7dqa6JsDkvajBnPX7ntuWFL1fyla8+d94Lk96thpHyQ8ZSv+Refq38zvFw8apIQgBZzHHLdREnwSGN09BLKguQvwQAyHTNyhh9o87YHmfyoD2yW88OIdOA5Ktd2caty9bdEOZWBME9e0d2jvXVf+KFydeef2d6ye/dfCARITLBY/fyycJbPwwXpkhwQCYrGRCRMdSYpmlM1xhjTGNMOhGCiHMRJ0mcpEIIIpGGbhpUgvl38PSzRm44M3Egt/suZ/wOze677qwqw7j16BkREpFjag8fmqjrjYh++Pq11y8u9KoAiaTI4tLc4mt/Wrn4qkgjQMY03dA1yzRt07BMwzB0XdMYY9LZXu7Gyz4d80vFpVK5+k9yKyLB4/J8XJorv3PcGtqW23Nf3577zP5xYAxISXHL0TMiFAS7xnL7J/vrP7kwU/qzk1d4bybl6zEk7+qp/MtPh4tXkTHbtrOOk8vYlmnomrbutBkRwzjywxBuFCdKJxZB8DTITwULV4pnnuvfe1//gUetoe2ATDbcUQ7qFqE3REhECHDX7pGMXV2mFETpt45fKrhRLzqiUoFEonz+xfyJb6R+2bHtoYG+XMYxGt5QlgtRKFUWS+U05avJVdpGIkrcxcU3vl+++MrAHQ8PHHqf0T8KBLdPMLnH6Q0RAkDG0o/uut4F5PjZuTcuLfWgAK8rsHj6mfyJbyKPRocHhwf6GpFfXTZBFOeXiq4fNCIkaRgJKPEKC69/t3LljeFjT/bte5AZVjWIqkxiV9G70ldjYNElmm78V08E44PO9pHqdseL5fB7J6+kXPReRLSqQCqdeTZ/4hsmivGJsVzGacQiUf27FS9fKMq0cuOmrCpFomhpevbH/8W79vbIfR+3hrYrk1iHMTY8NNTcU92KjnrDEhLQnvG+bM0Xfe6t6SsLbk8+NogAWLn4cv7ENzMGTo6OW6YBsL4M5Ac45/lCqVB2hRDNyabqoPK0/M6JaOnq6P2fzO29D5EpHXaRHuizQkQMce9Ev3xKZgv+c2/NUA+Wp8m9bvzZc/mXn86ZuGN8TCoQ1rsWqZAkSafzS0ulStMKrCOlGBXnZp//z0uvf1eksdRht+/Qu5QeECEA2Ia2Y7jqi77w9sx8Kegx/dXygUllMf/y1zMYbxsb1XWtkedeKjBOkun8Ytn12mWyZHkAj8OFk9/JH/8aj1ylw27RAyIkgD7HHO63AWC+6L9wZk4m2Lp9XhsDEYkni699R/fmJkdHNK0hD7CmwHR6ftH1A2i3/UdEEqJ4+tn5l76qdNgtekGEBIM5K2cbAHDifH6u6PeaAAEAALF86ZXwymsTI8PSBjaowJTz2YUlL7g5Gdi+80ICKJ1/af6lr/HYr27fp9hEekCEADSUsyxDq/jxS2d70AwSAWBSXii8+b3hnG1ZJjQmJ6mHhUKp4vkNfqU55JHLF15aPPlt4qnaLHmT6QkRwmDWQsS3ryxd7aGgaP05ZhoAFM88o/mL/X0bay9bcr1C2YXOR6Gk4IunnymefU7+vQt37N3KVk9REBEC9mdMIej4ufk45Vu/c3bV1WQakEiDclycDfIXS+deHMk6GmtsKgiAAHGSLBTKrcdCGwQRBU8WX/uuNbQ9s+0Qbda4iq0uQgBAhJxjzCx5Z68Vt3iZaG1RkiaSMMxfcqde82fOxZUFkcYIYAyOQYOOKAARLZUqURxv5vkjstQvLb76bWtwm2bnVKn35tATIkTb0N68vFj2N/WJ3CAyc8mIx9706eKZ54LZ8zz2ZRcB+c+c88YPF8VJ2e3sVHBlEP2586Wzzw/f81GlwM2hB0TIEFMu3ri0KGiLNtKueZgYFaeXXv/vlcuviSQEZMi05Z+JNtLJq+R6SdqFfifVutYzz2Z3320NbgcSSoqdZqvPrwCAMZhZ8qby7pYU4PWSzsqlE9d+8G9L518EnuiGcWusP0oS0VgLkzTlncgKNgzG7mL53AsAyh3dDHpAhERwamrJC5Nun8iK50aISIIX3/7h7HN/FBfnHMfZMTG6c3z01gBSkiQNdtQLoiiOu3a9UvmVS6/GpbnqknxFJ+kBEXJBU3l3S/bzrdrA4ts/yp/4hoiDwf6+nRNjA31ZZCuUnqScx0lD0vKDqNvXi7G7VLl8Uv53907jXcFWF6F8yrv9RK56dgDoXnp14eR3KE2GB/snx4ZNQycC1w9uap6HiEKQH66/24EQItzcoOgKF4YIRJVLJ9Ow3N0zeTew1UUIstR46ymQiAAwLs4svPonPPIH+3Pjw4PSBU3SdLUaFz+M1p0WctGdFrQ3gxgVp4PZc7IJarfP5namB0S4NUFEEunSqe9HxVnHsceGB1nNBa14QbTKjC6K4mg9j5Tz7rSgXeEC08S9/DrxRIVnOooSYVMQAWIw/07l0knGtNHBfkPXq/XWKS+W3dXKYlLOXS9Y+9hciK1SQo3Mnzsfl/NqWthRlAibApEEL184nkae41jZjAM157PkeqvN6Kp10p6/dgJQdFuE9cEFUWFxtnj1jLKEHUVvuk8MtNBXo1Qq9fivFVOv6M+eQ8S+TKZeERonSaFcWbs6NIqTQtkdGxq4qYPo1pn3IgIRhUniB2GcxOXZ8xN3faDbJ7UZCCGWCgXLaMYytaKjHqiY2YogJuV86hc1pmVsC2pR3ELZjdbM78mPLRXLQgjGGAnKZuyMbTHGoFa3LcNQm28K6y+CJOV+GIZxLDtNBsV5kcZMN1seQbEySoRNknhLIk0s06y3KoyTtFTxYL0yF0TkQiwWq6H/pXKlL+MMD/Y7lim/yGQj7U33SBFREIVR7IWhLHNFRCJMggpXIuwkSoRNwkMXiHRdq7dd9IJwrclebUWCnO9h7b+FECXX88JwqC832N9nGnq3poMp524QRtIALnuPiCQUaaxKZzqHEmGTCJ4SUH17FiIKogjWMIOInPMgiuM4ASBD1y3LNHSdIXIh4jjJF0plz885Tpwmmx+YiZLE9QP5ErnhEhAE57SR9R+KjaJE2BL1x5WI1s6wR3FSdr0kSQBACBrs19/3wLFH7zvWl8ssLBVfO33hjTMXlycYNzNOE0Sx6/syObnSuKRsYEdRImwSpt1w64SgNZYLhlFcqrjyA4LozoN7/qcv/Pyj991pmSYAEMBTH3ni9TMX/vibP3j17fOwKQpc1lE/qvjBpq3fV9yKEmGTMMNGRBJVEyGIxC0+ZD1vIRUoQzJH9+/+nd/4q3ce2MuFSDmX8VLTNB6+984De3b+h69+5+t/9qwQQm6H1tHmTtKFdoNwbQVibbNERYdQImwSzcoAMlndUs0p3OKyyaLtiudLBQqiof7c3/vi56QCoWbx5J+c86GBvr/xy09Zlvl7X/lWknJd03SNaZqms9oGhW0qoxVESZoGYRQlyTopSgJkGtvyfX16GiXCJtHsHGM6F0IQrfGERrGMxAARAdGnP/rE+x68e8XSUEQUQlim8cWf/wTn/N9/9TtxksgZotQeY6gxJv8nt+xlyJAh3ijmFSAiGYkl4lwkaRqnaZqmYlmcdg1Q05HpalrYOZQIm4M0u48ZVpoEnAtd01Z8mKW/J02NEGLn5NhnP/5BjTG+ivsnraWp61/87Ccqrv/0956LkoRzTkREJASkwOuflH9K68hqKiUCrbalL1SFJ4hAkBCChKyIq7nNjRlVYpqBmtbAJxVNokTYFESaldWsbBy5SZpaprGio5hykSQpyPAi0ZPvfWDfru1rr42UOnQc+4uf++RMfunk2xeSNA3jOOX8pgSj/LOJ1RYbdWg1w0RUIuwgytdvEmY6emaAamv/GOKtE6ckTaurB4n6ctkPv+9Bxtbf7EGazYnRoV//7E9NjAw6ljXUl+vPZsxa35q6Gptjw1eqm8s7VinajhJhkzDdNPpHiUB2rECGtzaVSdO07ose2rvjyB17GswEyIjOvUcP/MInnzR0DREdyxrsyw3mco5lyYFomWPZOQiAaYZaRdFRlAibBZk1MCkzEIIIAfQbJ05ElKYcaq7jg3cd7s9lGz+8/NYnn3zsY+9/CGqbNFqm0Z/NDPbl5O72dcPYUTWipqkUYkdRImwec2ACdSNOUsEFIhrGDRNsIuKiGkexTPPeowfYRjY8kgKzLfPXPvPxR+45IpZ5oYau5xxnqC83kMs6lqVpWkfViCut6K0PtFXWH/cyKjDTLERG/5hu5dKwnHJu6JpZM0312IlM5RPR0EDfHbu3b3TRoPRjRwb7/8bnnypW3LcvXNG0619njNmmaRkGFyJJ0yhOkjQVN+qwLRaM80SuaVp26YSIgqey53+3fxM9j7KETUO602/0jQjB4yQFBMPQb1h8UKuhIaLt4yOjQ4Ni40ZDFtns3j7xd//yZ/fvmpSFbzfJTNc0x7IGctmh/r7+bMaxLF3TWP1FsIwmLhIB0sAlfsMiSdmlu3TlLR6H3f4t3A4oETYPM2xraLsgipKECAxd07Rl97P2zBPBzsmxjGM1N4pMWhy+Y/dvfPFze3dMpilfLcco1difzQz19w325foyGccyDbnaCnG5y7oaKw3PwlI+LC9Ii1f9GGL52tnStTOa5XT7l3A7oETYNATI7NHdiCyKEyLSNK2+wHc5iLBzckzXW3LbhKBjh/b9o7/+ywf3bF+7gzAiaoyZhpF17P5sdqgvJzXZn830ZZxcxsnYVsa2HMtyLMsyjbpK4RbLKWUZecXLz325fOmkSCJZFyDi8NqJ7ziDk4zpqhti6+hN94mBFvpqDCy6RNM93sILAcga2qFZmTiOhSBNY5Zh+EHVQxNU7dfEGJscH2m9Z4UQdOSO3b/5t3/1//i9/3Li1FnLNJdPQVc+RVlJc0vktsrycjYhOOdJyrngXIh6Nbo0sOnc2ZkfXunbc+/oAz9jDowXLp70l6b37zxMt9feaYyx4aGh5p7qVnSkAjMtQGT0jRp9o0nhasq5rjHbMuH6FjHVT+m6NjrY35YBORd7d0z+L3/7V//fP/z6d585bhiG3kpBGVbrTqsqNQxp+2Rxmyxw1RjTNI0hCp6W3nk5rixktx+Zeu2HuYkDVv+oKihtC8odbQnNdOyRXVxuMoFgm0Y9Za+xanmKoev9fdm2PK4yTjM6PPj3/+ovffGznwAiPwjbmCSQZai6phm6bpumbVbX/kNNsEH+0vTxb3qF/Oihh5HpKj/RFpQIW4AImOaM7yNkYZwQgZxhVf+1tjeoaegZ26Y2GQ2Zt7At89d+7uO/9T/+2uToULFc2YSdDKmmQy8Is+N7B3ceBlLrgNuDEmELIAKQPbJbs3JhFBGRpjHbrHUlk1aCwNB12zbb6LjVp4JPPvbAv/zHf+vJR+8vV7xybeV+p64VgIi8IIySdOLY47rTHgdbAUqErUJk9I1YQ5NRFHMuENGxq6mIWrE0aYzpmtZevw0RCYAL2rdr2//6d3/9N77487mMk18sVDxf1sq17/qIC5GmPIzisutVKm5ufM/YoYdVULSNqMBMqzDdzozfsTR7Lk4Sw9AztqVpTAhCRFnwpWlMa2BlOtZWAVItVbBO/1IAAOBCOLb1+ac+eu+RA//6Pz39zPHXPT/I2JZtWbpRnc6tCy3ba6K29penaZqkPJXb0xDJaA3T9J0P/KSZG1IibCNKhC2D6EwegFNmyfXk0nXGGJclXbWQxnItSHXJ1JwgSjmPkzSKkzCKwyiO4sS2zMnRIdsy5ArcdVsJy03a7jl6x7/4B3/t6T975g+e/rMrM/N+GBm6bpmGaRq6pq29iEm6mpyLOEniRG4oLFbYwo3E2KGHxo48qhTYXpQIW4aENbTd7BtdKlwrlF35s6r8mGweI3htl2wiYgz9MH717Qtvnb88NTN/dTafXyoWShXXD/wwSpLUMo1H77vzb33+qYfuOgQNbFNRa1EjBvpyn/2pJ89OzZ57+ru2ocdxHMUxY0zTmKHrhq5rmqaxakcMiTRxSZomSRon6U170dTHJSIg0Te5f+/jn9VMh1RrtraiRNgGNLvPGt8XLl2th0DlMyq9UNmHBgEEEWNYLHv/87/8/a98589df9U90qam55478eZvfPFzv/qpjzi22cgqRMZwajb/T//1f/ryt38QRrFtGkN9Wcs00jTlHOUC/1sX9krnc9mSCLjeNQ5r27MSEUH/tv2HPvrrmZEdSoFtR4mwVYjA1LVd+w6551+QXdXkz7G21l46nPKZTrn4V3/w9H/8+p/KNEPGsR3bMnRdttJPuXD9oOL5SZJem8v/w9/9N6fOXfrNv/7L48MD6/p/QtDv/ruvfOnrfwoAo0MD73vw7g88fO9If+65l187/saZpWJZELGVnNKq8AAMXR8e6Nu1bWzHxFjGsYpl99zla8WS2+fYuw7ePXjvT4V9u7ggJcC2o0TYEkQwYNGnDySjh3b+k1cGr8zkpQuKALIhGiDK5oIAyBh8+U+f/X/+4Gv9ucynP/LEpz/y+OTocDZjm7ouAzdJKsquNzWTP3Hq7J+/cPLk2+d+78t/cueBPX/zF3963b17EfHoHbvfe/+xxx+8+1Mfeuyug3sd2wSAT334sfOXrr1w8tTx10+/c2VmqVSOoqR+NC7E+PDgrm1jR/bvue/OA0cP7JkcG5G7RCVJOndtfmmhmHOsgf7BkPRXS6XvL+Qi0WC4R9EoSoTNQwQE8Ng28eg2HobZh+46pDNmmobc22husaBpDAHShPtBqDH27Cunfvffffkjjz/013/xpx+996hl6kR0U79SRLj3yP5PfvCRv/35p/7i5TeOv3HmJx6+d901UHLe+MXPfOzzP/1kLuPIhL7MVZiGcdfhfXcd3v/5pz66WCjPLSwtLJW8ICQgIvjvz7/64LGDv/TJn8g4ttxlsbr8SgjuBkOWNbxjUn7ShuSJ4fRaaJwsO0qD7UWJsCV0Rnv6iYjm5xcfv/fo4/ceHZ8YGxjoyy8Vf+v/+g/vXJlGxISnFc8vlN0fvPjab/2tv/Thx+7PWJZMvq3sHAIhwFBf9tMfeuypJ98rizkbiZFqGss6ttzpafnUTwgCINMwtk+M7pgcW36kn3z/w4Wym3FsAEiX+dKJF6aB3J7p+hEMBjvt5GTZub3KtruPEmFLIABDEEKEYSQzAW65MjzYv2/XtjsP7Ll4dYYx5FwsFcu2ZfyNX/zkcH+u3v3+1p16rycKAQig7jQ22Bvqpv+Wx2S1rdsISLYeXR7zzNiW1O3yI4iUJ36tXSpR0fOXXJ8Idgz1M6W9DqBE2BKcsBJfj8EAQBwns7Pz+/btfvCuw9977gRjLE7S/FLRMgxd01aTn8ZYkvKK53MhchnHsUzRQL5+DQiAMeZ6/qnzl6dm5jXG7ti9/ci+XZZ1Pda6vIXpDRcVJ8SFLBafKZTzZVcmLvps0+WMAJQU24sSYfMgAieY8xERDfP6nfS8oFAo3nlwz9jI4GKxTESzC4Vb5QfLcoCvnXnnWz984dzUdJrybWPDH3r0/g88dI9pGs3pkIgYY+cvX/u3X/n2a2fekdutZR378QeOfeEzHxsfGVrbv+VxKrMWM4XyfNmtropEYJq+4KsHpv2oe9oq11xMBNqWBddXEtJSobRr1/bD+3a9feEy52J6Lh/HiWXdvOO0VOVfHH/j//7Dp+cLJfndS9fmTp6+cHl67lef+uhNHdwahDGcXyz8n1/62utnLiICY4wx5ofRnz77cpLyv/eXf65e4HorRERcIMBCxcuX3foVGZoGup2PdGUF244SYUsgwKyHpRgdx2IMRX2nNC50XfvZn3z/YF/2ymy+P5uJ03RFEc7kF3//69/NF8q6phHR2Pg407S52dmvfe+5I/t3vf+he7igjT73CPjDl1578/zlbdu2PfjQQ2dOn774zgUAYIw99+qpD733/vc9cKx+qjdDAESJEAsVb3nH/j7bdMkuJMoVbT9KhC2BAKUYZlw81GcwpgmRymYzIyNDjLF7jx649+gBznnKub5y+xk8+faFqZk8YyiE2LN332/99u9YtvPb/+Qfv/7aa8+8/OZj9x9rYluyJE3fPHcJiH7l177wc7/wy8df/PE/+o2/4/s+IoZR/Nb5y++7/9i611VH9h0eymbeiMxIqGU37Udvuk8MtNBXo1Qq3SYxboRE4OUy3jmk6YaepiljbNu28aHhAdnKXnqDZq1x/c0zMaKZ+UXOuaZpQojh4eHde/aZpjk+PgFAc0vFOEntW+znughBUZwQQKVSSeK4Ui7Xq7EJIIzitVcYE4DO2Fh/7upiUUZobdNwLOtKyRAA2u3xi1v5vomlQsEymnnRtKIjZQlbAgEEwVQFBWgZxw79UNNYNpdZsQXTCrEQhIxjy58zxt5+69S//N1/blr2yy+/xJhmW0Yja6BuxTD0HROjQPRHf/gfX3rh+WtXr4RhWM0lMrZzcgyRrbqhE1azJCO5TDkIC64PAP2OFYMxE6oJYUdQImwVRLjmYjFm/f3ZQqEkhEjT1LLMBqOaxw7s6cs6FT9kiFEUffO/PQ0gQyl476H9MkC6ofORSnv/e+7+wQsni+XKq6+cqGdQhKA928cfuvvQOsesNeYQggjA1LThrDMT64XkNraC3US5+K2CAMUILhQxl8s4js25iKO4we8KQUf27/7oYw9itSqlGsnkQhw7sOdD732gmfNBFER3H9r3+Z/5UF/WIZn35yLlfGJk8Nc/87Ed46PrihABwjjxoxgBhvsyjmWe9axQTQg7g7KErYIIKeHJPHtwQh8ZGQyCUK4bagQiMnTtLz31EUPX/+z5E4WKR0SObd1/5I4vfOYnJ0aHGtxK7dbDMsae+vD7dk2Ofe/Hr1yZyTONHdy9/WOPP3Tkjt205hpFufEvAJSDMOY8Z5kT/blKqp12LQBVrdYRlAjbAAM4V8CLJTw42O/7od5wck9arf5s5ouf/fiHH3vgnaszacq3jw0f3Lsz49hrKHD5tjO3fqY+/Xv03qMPHjsUhCEiyhLtRgpxkDFBUAkjU9d2DA9YunayaM2qDGHHUCJsA4jgpfjsNW3fAG3bPr7B76IgYozdsXv7wT07YKUiz5sgAkQsuz4y1pexVzssAHAhNI3lshn5Q35jYfdqMI0BQr9tT/T39TtWOdVeKmY4oUoRdgjl5bcHBHh9AV/PM11jjDGZ8270uzWbxoXgQsjJ4ZrN7YGI3r54NV2v3ej64dmVYLrGGI4P5PozNgEcL2WmQkMJsHMoEbYHRAg5fuuidqWMDAkAEo4d6oeEAEtlFwCH+nMdOb6uoaYxBAZ02rWfWcq2UEmuWB8lwrbBEKY9/E+ntVML7JrLjs8xuUdoe0eRe7BMzy9tHxvqjDIoIvZqObMQ66+Unafn+ispQ1Tt1TqImhO2EwS4WGb/9k00GYw6dP+YcNr9lkPEJE0rfnBoz/bObI4NxRC/M5sVwvE5i4U07MoOdhAlwnYi2/2GKco+asUIM0b7hVLxAtMwrGYXOq2BXCt4zcVSjJw0BFAK3ASUO9p+pBS9BGa89juMiFj2gv6swxqIc2744ECC4GIZUwEMobbUX9FZlAg7AiIkhJcr7Y/NIIBsK9qhWVqY4lRZhWE2FSXCDjJVxoi3ukHvishuwm2fEyLAQoBzvtLgpqJE2CkYwKyPS2GbH2gCGurPLRTKgkirrZBq05EBES6X0UuVBjcVJcIOUonhSqXNrh0RjA31m6bx4hvnzl+ZjeKkXQMgEBd4oYRcqBrRTUWJsFMgQirwfBGFkJ5jm+wVESLefWD3gd2TpqG3V+KVGC6Xe77BtiCSG1p1+0QaRaUoOggiXCwzN+G5DS+OX+OY1eXCowN9MIiN7GTYIAzgmouLYW/HQ4lo12iuzzFOXy22PYXTIZQl7CAIkPfhmous4brNhg5bW3R7U9PeFiGA80UWcexpFQqie/aN/tR79mq9U2+uN90nBlroqzGw6BJN9/Qvu0FCjmcL7MiwaP1QHYbCFM8XkXr+xYw6w5xjmDpL+cZuO2NseGiouae6FR31+A3f2kgTdaaAftKRREU7TxVg3scZD2+DBwIBspZuGdqWvuPLuA3u+ZYGAaY9vOoiW0+FywMJbYziNHJAIkCA8yV0k553ThBAY8y2dMfUt/Z77zpKhB0GIUjxzUUmAHDNhwIRBeduqSw4ZxqTm3c2Py4REDG529n6mzpRyPEteZI9L0MABEvXMpbeIxpUIuww8pF+Y4EVGsnaI558/pXf/xf/34lnXuG6TagRVTe0rmlyteeq+oHa5wUhI8N567Uz3/rDp/2Kt8aY0gxedfFi+XbwRQFAY2jorM8xt/gUoM7tcdu3NAgw5+Pr+XVutezO9OD7H2a69rX/8PUgu8fc9x42cRgHdoA9IHRLoEaERDILtvx/RISCaUK3wR7A/u1s/JCx5wFt1/3f+5PnojDKrrn2F5EE4Yk55iW9HRdddkWIiH0Zo9sn0igqT9hxEEEQPD/D7hsXgxatVo4iE4CZXPYX/uavfPNLX3/1+9//yBf+it43QkTEU5HGlIQiDoHHIo4YA8aYEEIAMsNC3ULdQsNiuolaNYP/8ne+TUH5Qz/7lPzkqu3VAKc9PJlncLusmJDJif6M2SsXpES4GSDA1Qr78Yz2sb1r1WXKba6dbOapX/vMy8+98vxX/ujYBz80MDrGdIPpBtjZRsbiaZqfuvzjp7/+4te++nNfeGpobERwvpoCBU8B8blps+01rl0DQZb8DGQs2Yxn6+frlQg3A2kMn7nGjo2wXbmUc840A1HmLW7uxURCmLb16AcfPnXizT/8+38HnYHJfftGd+0cmpwcGB3LDg6ajqMbpqbr0qbyJInD0CsVi7OzV8+cOXf8+JkXXyovzH/ur/3isffcQ6vbQM6TNCxf9AeOzzK8LUIyRIQArGoJDQ1R9ELxmhLhJsEQlkL8zkXt84cTjEu6mdVNZ0V5SL+Uado9j9w3OjH69O//169++SsEMDgwMDo6munrMx3HdGzdtOSWEkkU+ZXK7MxMYWkxDgKepHY28+kvfOb9n3wSVu/zK3gSB6U44X9+VSsneDs1uJfuaNY2NA1FqkSoWAYCvL7A/iKnPzEKcVgGAN3K4Eo6qTdB3L535xf+wf9w8J7Dz3/jh+Qn5Pme57v1tztR1X4hmmnKUiE4DU+MfurXfvaJn/qgpmmrKTBNkyQsC57EQlu8bRzR63cPAEDX2NZ3RCVKhJuH3F77R9f0Qxlt0knDoKylqZPpW3ELJ4kQwnLsD3/mY8fuO3b8u8+ee+V0UPEB8OZGvASGpo8PDw3tnfz4L33y0D1HYXUbGMehVykYWtVJ3vgepFsaRNQZAwCNYa+sB1Ei3FQQwEuxlLBtDiBQGJTTNM31Dcqs+moN7RFw+x27P/FXfn76nakzx09dOf1Ocb4QhZFIOSBoup7py0zu23H0kXsO3HfU6cvItMWKCozCoFTKW4aGqElLKnrAX9vgTUaAqgi7fSqNoUS42QiCIGUAgIimrvlBmfN0YHCEMW01HQKAEELTtd1H9u86tC/0/PJiqVIo+RWPMcz09w2MDfUPDxqWQYIEv7XXfTX8EwZesZi3DE3XtPrJ3G6WEECrWkLljipWQRB6qWxLAYhom6brl7lIBwfHV9xSW1KVIheIaGczTi47sXeHfMQI5JrhFeV33Sn1/UqxkNc1NGqjyB1OebdvSJupNokDptxRxcogEIGXalT3mjSWsW03cJc4HxoaN0xrrW/XnipZyEar/GsdqUAi8rxysZhnCI6VWf4xASjL1m4bsBYd7Z24jCpb21xkZtBNGQHUKxsNQ3csO4r8xcWZMPTlD1tfSFFToKiUl4qFeRAiY9ty8ln/zO3njkLtZcQQNdYb7fuVCLuAl2o3PfqWaVimGcfR4uKM55bqFqzpIQgIETnnxUK+VFoUQtiWJR3RGywh9cZj2jiIKC2hckcVa+GnjBPWX9NycuhYFuciSdNCYT5Jk/7+Ica0podAwCSJi8V84LsAYBqGZa3Q6EYQ3GbR0Xrpj4bIeiQ8qkS42SBAwFkq0Kh5IbLEkTGWsW3XD7jglfJSEkd9/UOWZePGFxgJIaLQL5UW4zgEAE3THNtiK2UjOYG4raaEgLXaUcZQYwi9sJWG3nSfGGihr0apVOoRT6EjhJzFAp1lP5Ha0HXNsS0vCIgoCNwoCizLsSxH1w3GGDLGkMFK8U8iQUIIIThPU57GcRhHgRBCHtmxLJmTWCFyA53aRLF7VA1gE+6oEGKpULCMZuZorehIWcLNBgEijhHHFdvOmIbOhRVGEREJwYPADQIXEWur5KSSbhYh1Nbz3jyNRLRN0zRW/S3z23BOWLWEiKDcUcWqJAIDvvLrFhEdyxRCRHEMtYqZmswaOvjyNIah67ZlrRGqJ+qRxecNg7WpIKtFaLY+SoRdICUMOFvREsppm2NbXAi5JX1z2S4i0jQtY1uMrVqYKpP1cPulKACgKkLWE68YlaLoApzAS1eOfErTpzGWtW25DKKJ41eVvPpUcNmZ3IbuqCxbQ4ResYRKhJsLESIQMD9dNf1QD9LcmltvbAQCRNuy1pgKXv8wICHb+vHDxqmnKHrIHVUi3BSqQkJgTPAkWLw6t7AkmLG2wExDdyxrQ1l7+UlTN2zLXNuPJSJgesUL/PmLIvKv11z2OKw2J6xNDnvA0qs5YSepLrpFYIx4ElcW/NkL/uw5Xp67+vCD+PFfhpk3KPZwdQHIjemDKGqkV4pUoGEYGWflrOCyzxEaGX3XffnzL83/+I/A7rfH9me3H7IGt2mmAwgttTztLrXYMSLIhYVbHyXCDrBceyJN3EIwf9G9djpYuCwiz7FtTdM8z6OBXYbTn069LPwlrBd0Lz8MACJKmxZEkcz7gQw8VD98s400DCPr2NoqqxPrX2DZUX3X/drg9iB6lhEnf7F4+krhzHPW4LbstoPZbQetwUlm2tVr6SnqXigC6D3StEOJsH3Um00wjQRP/WKQv+ROnwnmLyZekQTXdCOTyeq6LoTwPC+OIntwG+5/XzJ1QpRn4NYmF8t0qOtaFCdJmgohZMKi9qFq7pAhMwzdNg22tgIRtaHd+s77mN1PQpSKRSDSdSOb7QsC35+/6OcvLp1+1h7alt12KLvtgDkwwQxLLpe6foFbGKz9gb0zJ1QibJ1aZRTTgEQaVIKFKW/6tD/3TuwuEU+lVTRM23EcrbaaNvSDMAwHgFhmyNj/3vTqSb54kVbSoUTXNM3RSAguBOeiagEREVHOgmRBDaze1YKIUDO0yaP65FHUDABKkqSwVADZV4qxTCbLmBZFIY8Db/aCN3dBezvrDO/Ibj+cnTxg9o+hbla7gG9VNdKyPCEiaJpyR98lIAMiHnnh4jV3+rQ/eyGuLIg0rnqkyBDRNE3bdlhtioKIYRR5fgAIIAQzM8aeh9DM8NnTJNLVu/QCMsYYWzvqueKqQgBCq1/fea82vAcRpYriKC6XSrBs41HbthljYVgteeOR706fdWfO6U6fM7ort+NIZuIOIzuMmr5l1YjL+u8oS3i7gwgEPA6iwrQ3fcabPReV5kUSV10hpkHNKNm2bVn2Td2coiislMsISIhAhJqh77gHzUx67XVKwjYuR61OAvsn9Z0PaLkR+SNpQsMo9oMAq0Ve1T8ty2KMBYHPOQcAZIyI0qBSmXrTvfq2nhnIjO/L7TjijO3VMwPINCBRP2a3fyXVX0v9WlRg5rZDPmeyzUQSRsU5b+asN302Ks7yOASoekK1zxIAMKY5jmMYxq391NIkLRRK1b9IHSLTxg+hkUmunKCwjO3IGRARMsZG7tB33MPMTDVeXzus51Z81711EMMwELNB4Kdpev20USOixCuU3lkqX37NzA1nJu7I7Thij+zSnT5grDZN7fKyheWWUAVmbheuhzpRpHFcyvuz59zpM+HSNI/96iwEbxCMVKCu646TqbeNucm4CcHL5cr1yGNVh6gN7QTDTqdeFu4CtNLCvZqHcLRtd+njB6sma9nREHGpWAnDcEXN6LqeyWbDIIjjpK5DrDrYQEJE5XxUmi+9c8LsH81MHshtP2wP79SsrLyQLv66GF6/1bqaE/Y2K6X43Okz4eKVNPTq/3prVz35yBqG6TjXJ4ErHZ7K5bJYvsC+9uhouTHc/77kyiuicKW5rRTkJJBlhvSdD7DB7Qgru4uVipumyWpH0JjmOBnEMI5vzlLW1Sh4GhZmwqWZ4rmXrIHx7LZD2e2HrKFtmulU7+Fm/9aALVvp1Rt2UInwZm7QXpp4S/78Re/a6WBhKvXLRAKQAQCuoi75sFqWbds2rp4ulxu/VCoVIWiFlzUJZveZex9NDEfkzxOJDelQ5iHY4E5j5/3MGVwtfEIEbqUi+MrN1rAWMpWvkjAMVm/HiIAg0jhYuBIsXCmced4amsxtP5zZdtCS6Q2o7li6OZNGxHq6HpIN7lnfLZQIAeDWFF8hyF92r50O8pdkiq+mPW3NYxBjzLYd0zTXUGAdt1JOUq6ZtxxTuqaGZex+IDUzfOYU8aRBHRIRaro2fljfdifq9k2TwOWIqilefcu02iXUQzVrf1imOngS+nMX/fmL2tvP1NMbRv8Yq6U3Or1NkobX1/LGqRJhD3BTiq8cLEy51077cxcT73qKD9fr9SIngZqmOU7GMKp7U677qHmVSpyktrnSwaUOma5vO4ZmJr16kmJvnT4XchJo5vQd92ij+xAZrLoVIgAAF1QuleSLY7XP1KeCpmkiw8APOF9rdVUthINEdD29Yeec0V3Z7UeyE/uNvhHUjM6mN2prngVRokTYA8gUX+gFS1e8a2e8uQtxZYHSpEHtSWphGMNxnDW69948MoDnuVGcQHaVRqP1UM3ofjScZOoEBYXVQqbVYGxuXN91v9Y3Ln+09iOepMKtlBu/VYZusCwLAj9JknWt2XI1pqFbuXLKvXZad/qdsT25HUec8X1GdhCZ3on0Rn0LCiKK097obKw33ScGWuirMbDoEk13beJcTfH50dK0O3PGmzkXl/M3pfgapBaGMWwno20oK4UY+F4QRDCUW+MzVR0ObMc77OTyy6Iyd2vIlIgAmTa8R995H7NyAASw/mOdJKlbqWzotmmalslkgzBI4rhBr/KG9IZfSi6drEy9aWQHM+P7sjsOO2N7dae/7clGeQyiDc8JGWPDQ0PNPdWt6OjdZAllii8Oo+KsN3PWmzkbFufELSm+xqlPmSzbYQ1MAm8iCgI/CGolomudMwCxzLCx/7H0yqu8cHn5QESEuqlN3qlPHEbNqLmg659GGCeeuzERVqvbnEzIWBSGG7reZWoUsbsYVxZKl06aueHMxP72JhvrO1AIId3RHgiR3tYirIc6EUQSxaV5b/acN302LEzzOKgXGjZ7bGKMWbZtmVYjYZibQMQ4Cj3Pb/RxI8GsrLH3YTQdPn+WhHS0CO0Bfed92tCuejFagycQhlHguxsyPNer2yybMRYGwRqhmjUOUks28qg8H5XmSu+cMPvHMpN3tJ5spGXRUS4oVdHRrrE8zZDGcWXBmz3vTZ8JF6+mkVf9Ra2U4mv48NUwjG07hmmuuMtnIyRJ7LmuIGiorkO6prqp77wPzAyffoN4wvq3GzvvY9mRJuIcvh+EfrBRQ3G9us20GLIgWCdUs96h6snG6XBpupZsPJjdfrjpZKNWyxMKooSLHrCDt5UIb0yvJ+6SP3fBvXYmWLySBpU10usbHGT9apgG4WnqylRhg5PQashU0yePItOFu2DsfhB1a408xGoIQt/zoyhoJVtgGIZMXTQSqlnzslZMNsq1VAetwckNJRvr28BwQSpPuGlcTzOQSFOv6MsVtPnLaVBeluJrQwXTsjCMo7XQo17COXcrFS7I2GCJIwLA2Tfp7Kv0s3fg0CQIsdF4BhG5npvEcYv3Q4ZqwjCIGw7VrHVd15ONkUw2Lp1+xh7ekdt+ODN5wOwfY7q1brKRsWoAmQvBeW/sOHUbiBABIPXLfv6id+20Py/T62kj6fUN0WIYZsUDupVSygmMxo5DBIgEyF/6TvKVf0XlApQXjV/+h2x8TzW62DCcwK1U+Co1aw1Tr6rJMMbCDYZqVj3oDcnGwJs+582c1+2cM7Iru+NwZuIOs28EV9lQFeB62Rrnak64eaA3e3b+xJ9EpfnG0+sbpVYNY5tNhWFWOGlEIYRbLiepaKjdVm0NB3/lB8kf/+9UKQJj/PVnKfwn5q/8I7bzMJBofFrIObnlMuetptGWVdXYjLGgqVDNGgeX/1dNNl495U6f1u2+vj13j933MaabK32J6v3JUyF4j2z71htl5mtAxEvnXw4Wr5EQyGTRUjvvvGyArWlaJpO5dVlgi3huOU7TBpqpSQUy/uZzyX/+36iYR8bkqnpx9kT8e7/JL7wGyBoPKqacKuVS61sgwg1VNVYmk5W9Utty5OVDIKK0folfqky9kYbuaiGl+i7ZKSfeIztO9bwIRRrH7lLbtSepV8NkMlnDqL562ziQ51biOG3giUVAxs8cj//gd2hx5rqdlzq8/Hby736Tv/Xj6nLHBg6XcO5WSm0v4zQMI5vN6YZRv3XtRU4aRRLz0F1tspex9Xqbj17p8d/rIkQRBzysdGL+LZ9R0zSz2Wzj9WgbOHWAwHOjOF7/fY2MX3gt+dI/o/mpmz1tRGSamLkY//vfSl/5gfzJ2jokojjh3kZq1hpH07RsJlt32jsxhOBx4hVvtYREhIA7R3L1Am7sibBMz4sQIQ1cHm8439X4AIZptSWyutKxMQz8MIzEGg8rESDjU28nX/ptMX1htbkuMo0Wp5Mv/dP0+W/KpUxr6JAI4jjpkAgBgDFmmmbnSlVI8MRdWvGfTIPtHquWAUYJVymKzQFTvyjSFkPta0CB7yW6YZqmruvtdd4QIAqDMAhSASsGGYAImCamzydf+m0xdXrtVRTINCotJX/0uxR6+gc+i5q2WpxGEERR7HsbK5dp6GYRpWkaJ3GaJB1qfY2IJETiLt4aECaAoay1fSQr/7pYCXumgLvbJ9AqiVcgwTvx3pWSE0LEcZQksabppmnqhrGxQu01B4ijKAj8Fd/Xsj2MmLscf+mfiQuvo4y7rH08xsgrp1/5VxC4+kc+j6a9ogw5QRiGYeC366YRgRA8SZMkTjivxplq2yl2hMQtCJ4wzbjpju0a6xuorUq5mndTTj2xbX2Pi5BEXFkCok55jDUpElGaJpynLGK6YZiGqWla6w9ZmiSB56b8ZqMh+6HxSin5o38hzrwMDSiweraMURyk/+3fcCtrfviXGNKtOuSCgiCIwpbKZWrnSZzzOI6TNBFcSOvX0TW7AACISVAWSbRchETEEI/sHJJ9ZaKEvzNbho3VEXWN3hYh8TTxCpswUF2KnHPOeRLHmq6bhqnrOmtB/5ynnlvhgm5cGAGIkApa8oURky2TX42fKqDQ9LIxYrjJUEbTGN6kQy7A99w4ilq5IUKINE3jOE7TlGqeYcflV7tEHno8dHW7b7nT258xD+0YlP89V/CvLrg90na0xwMzIo1Sv7Rpy1WwhhAiiWPf9zzPDcOQc95cJFAI7lUqKad6gFQKhgtaqsQeOv77fl44/Y3vK08AQCI+9Eh04OGKnyyW45QLxBvmZ5yT763a4mmd4xNxzsMw9DzX970kiWULnI46nyvctyRM/fLyV4sg2jveNzmUkX89dXmxHHQuUtBmelqEyEMvDd3N9znkMyfjEEHgu65br2Pe0EFIkFcpcUFCENygwMQLOZBI9t0f3fWBxqvSkEg4fcEjnybTASIv4gvlJE6vLyYgolSQVymLDZbLEFGSJkEQuG5leUvSzdReHcHTxLseIJXbqt67f8w0NADwwuSVC3lBm2aZW6WXRVidG4TdGx9rwRseRZHnuZ7nRlEkhGhQjQTgVcqcC1nbgQhCUMFN3DAFWZqpm/6jn+H9Y43oUJrB6PB74733Q61HWxDzhXIcJ9WvE0HKyS2X6ns8rXNMIiFEFEee53quG0Wh/GK35CeHrscC6hc+2m/ftWdY/vX0lcLlfKVXfFHobRECpF6BeNrdc6g7Y0SUJIk0jHK7+Ubw3HLKuRShEFTwEjfkUKsOARLJ9sPhAx8DWn9lHRKJzEDwyKfJsJDqMRKMEpEvx2HMAUAQcSG8SrnBcpk0TV23EvjX1yt1UX7LSdyl2spmIIJ7942ODTgAECf8ubdnoqRtJaybgN50nxhooa9GqVRqxy2iuLJEQnQuNLoh6jUiuq5pja4RBM910yRJhUVERS+pBHy5POQ6heChT1mn/kLPT63jeJOIjj6e7L57eZ81RCDAOBULlWQkB4xhmgq3UlrvvKpomqbpuohj2Ly4S0M3O/GLIo010yaifsd45PCEPL3TVwtvTy01ZwaFEEuFgmU08zi1oqMt8fg2R61yYqvUB9b7jsqlPY14pIgQ+G6SxHEqil5avlGB1U8QpaO7goc/RddbsKx8O0RuKHjkKdLNmwI5cgPDJBULlbjkp2maNlguU28qI7eU6lAZWjMgpEFFxD4ACoJ7943unegHgDBO//y1q37Mt9L7Yn16WYRpkniFrdDJp77SwslkLHtDKy0wDPwkivxIlPx0xW8hERAE9/1kuuMIkFijGi089sFk552rtRtFxJSTH/EkiX3PbaylRm2lkm13aIVEs6CIgzQoE8BAxvzgPTtkevDVC/lTzZrBLtK7IkQe+2nQkdLtDXF9p/hszjTM2obpjeXWEeMwCkMf1mhUIyu1+sf8x36uPtm75SQE7x8NHv4Z0ow18hlyihjHUeB7jWb/sbr1tFwhYRim9JG7fNMBRJokXhEAHj0ysX9yAACmF71vHb8cp700G5T0rAirpdttq71qjvqS1kwmqzc8D1xOkkSB78Pa0Q5EIBHd+f54/wMrhEmJgCi6+8l0++G1u27LI0XVcpkNn6pcVGnbHVwh0SAIQIJHlcUdI9kP3beLMfTC5GvPn7+60P6C2E2gayJs+V51unR7HaRjJps7yF1Tmnsu0yT13cq6dwOJhNMfPPKUTADedC58cNJ/6GeI6eun9RED34+jqInfwK2T3q5JEZGAtLj8yYd2TwxmUi6+ffzSKxcWEFuKHnXrvdIdERIR561ecuwu1oPUm3/+IDfxy2Qtq6WGF5ynnttAmAQRhIh3382Ht99sDIWI99/PJ/avawahuoix0ly5zPLdfLPZnFxj2S0dEsG4Fd+9awAAnnlz+nsnr7al50hXDGl3akd1XWMMWhIQiaTDpdurjlzbgdC27XoqornfnqyAa3hpH4FhCzu74t1ovGm151Z4w2nM1dB1PZPNhUGQJG3os9YEiFgpLoWBf2bG+/qPL0Qpb33BhG1oRgdWb69Ld0Rom7qhYSu2UPAkcTejdPsm6tFC27I32vR6tQO6lXJj9gQhCVno3fJj1BeuYOSR09fIiG6l1Ho7JlkplslkooiFYbTRTRRbBxFLxeKzJ88/NyXKfsLaERLVGRl6m1uENUJ33FHbNKzWLlYkURKUNrNqdFnHp6xd6/jUlhPwKuWGisgQmVtgbgFuWt2LyEp5Vlls5GSIyC03Wi6z5rngsqBUpivZi7LrfuX7r+bLYVsUCACWwbpiCbsjQscyMmYrKkQeujz0Ni00Wp0EGkYmk5V7gEL7Kkg8t8IbKb5D1AozeKslBGRBWStMA67/2xSCGi+XWe90ru9emMlmjY71d1oNnqZecaF9FphyFjNNo/UDbZQuWULLHMq28MpBTP3NK92ut/3NZtrf8QkBfM9Nk3VFSACgLV7BlQLCmMT6/KVGwntCNFousyF0Tcao7E3LXsgy7sRdaqS7XCMQ0XDWaLzesI10R4S6YUwMZmiDfaOXk3hLYlNKt5soRtsYiKHvJfE6OQMCBMH1hSsrhEARgYQ2fxEaiDinSeK7DZXLNHGXHMdpJVvTBLG7RKJNj4Hg44PO5pz2TXQtT7h7vA+aVhFRXFmCDgcDbpgEbqwYbQPIdk+NZM8xibTFqytrVcZm4mDd4ZI4brxcZgNXccMUMatp+qZMETH1S+3KFZuMtg3nWj9OE3RNhLsmhjJ6k7+kNZretYtaMZqZzeYa34a+GRDjKGqg7RKyoKKV5mGV0jatOMe8wnrlMhiFQRT6nXh11W+OYRjZbNYwzY67pohpUOFRe6qmhjNsdPBdJsLJ0aHJAQNgwxvQAYBIo8QvdrCz5fWq5cwmTBLSJPE9bx2BI7LKAnNXkxkyr6gVZtZVchj4cRR1Oqp8064BnRuIJ0EalFt/EIho76jT3/cuE2Em4xzZMUCCb/yBkBX0nSrdvl6MtlnrdzhP/XV3rpah0chf9d+TSM9fXrdw1PfcJOl4rR8RMWS2bWcynZlI1wdq00oaFMnRPaPdqvzuZgH3XfsnbNx4/RRCGpRFB7tug2laLRajbQjB+fqVa0Ta4hXkq9wuRBBcn78IYp3YTFvKZdZl+S4xpmm2fLxVRyEhWl1TSgQAwzYc2TvZ6duyGt0U4b6dE3tGLNjwLcTEK4pW99Zbi+UdbDt9E6TU3UppjZtAACC4tnBlrQIdRC0/heulbbxKWWxiwa0QIu1sG2xKKkvUWL+clUEkEsd29o2PDm/abbmJborQtu2HD00Ajzf4pNPy/iKdIE3TJJEi34xQu2z3tPaThEmoL02v6W2iVphhazaAJAK3XCKxeaWeSZI0VIfQPJh4BeJNv5EJACyIHzq6c3NuyIroTfeJgdb6ashx94znxjNiPoINOH5CxJVFAMIGCkSaQJqmKApbbOy7IbxKRQix+nDIgjIrza/lgcuituIcH9y2WqyLSLiV8qaVtMg2bZ116atzk3CVPUMb+D7RvmFtOGssLCx0pd8SdH1R70B/30P7B4nHjf+eBE/lkuqOwjmvGcPNwHfX3LwakZUXmLdOrSzGgb5wZY3PCN6pHdFWJI5j3vEtWTCN/CZ7z8pSRIoeOTRuWtam3ZZb6f7K+vsP7diRFdCw5yeSIO1w6XbNGEYNNudseTgIfG8tzcvQaOyvfRSUsZnV65DStIEwbJvgnMdxBNBx11ckUdpcvgqRSBwe0w7t6VpIRtJ9Efb35Z64c0zjodztYZ1PI6ahx8PN6GohtzrZlHsg03fhqs9rNTS63uSKSJu/jGm82k1Mktj33c2ZEMZxzDfY5Ls5SPAmFrXJwFsWw/fftbNz8dsG6b4IAeDuAzvv3mY0ljOUlUotbWbSCIgIQHEcbcKThIhRFIbBykVnBIDVqtH1Vk4h6oVrGFRWfEMhYlzdEa3j1N9fnRZ8tRv3StsVrgURIhKP33tH/75dXTaDsEVEaJrmk/fvHbcaklbiblLpNmyiMUziOFyjpDMOtHVCowAAgIxVlrRSfrVPhoEfh1GnhUEAcRwJwTct8524hY1FyxGJxIFB8b579m7WOa7FlhAhAEyODX/03m22CGDtNWlEidvx0m2JHGJz3Ko0TXzfW/mSEFlQZuV8Ix44hp62eHW1+tLA95Kk406EqL+5NmuntMQviQ1e16AWfOw9e3PZ7Ia+1SG2iggB4J7Dez5wuJ/xcI2CQxJp3OHS7eUgghA8iqNO164Jzv1V45bIyvl1Q6PVj/JEn7+44tQaATy30vgmGU0Tx7EQYvMqwBB52GjzS/lcWSL4+H2Te3ZMbNYprsMWEiEiPnH/gYd3W8jj1XQo0ngzNySUAyVx3OGMMwghvNXiloja0gzGDaxgRgQiLX8JebLiS6OJHdE2yjIHfvPqMHncUBm3zFhqPHzy6MD9R/dt2umtyxYSIQCYpvnxR4/cN4m0sg6RR34aVjaztYxsiBbHUeeqkOWVequ1eyLSF6ewwaWriPritZVaYAABuJVSRzsyEVEkZ4ObWwlNXHbjXnNVdFWB0QcP5Z64/+CW6tK9tUQIAI5j/8zjdz60Q4NbdYiQBmXeiE1oN0mSdHpm6LkriJAAUKTawtVG27rJpk/u4q39Zmpt3Tp4CXIj8Y7epRWuGKCRMm5E1EXwE4ezT77nUNt7lLTIlhMhAGSzmZ9+/M7H91maqKfO5P3F1CvSpnfdlsYwijpoDAHAc90VdY4NhkZrH2dhZcXPC869cntaPK1IzQxu+lYQiLVy4pWyFLVfmU3Bx44Nfug9h+tLtLcOW1GEAODY9sffe/Sn7hrMgg9EtU1IKHaXaPN/zQAAkCRx56IaCBB47gqVa4jolbTGQqPVbySxnr8EQDdZBs5Tr5PlMmmaJvHmFfrdfNFe8dYybtmTkkgMa/7PPTz5xAOHtS1mAyVbVIQAYBjGEw8c/qXHd+/MRMATRITWF481i3SMOzgzlPmDFXw51Erz6JcbtYTVpk+XgHO6UbdpnARep/ZLqd2cLu2IhJD6JbG8xU5tJRry+OhQ+itPHrzn8N4tNQ9czlZ8MSzn4N4d48MDf3HyneOXfT9l3d2QMEmSNE0Nw4DGm843TBh4URjk+gdunAajtnRt3VWCN1Br+kRWZvkP4zgM1u9k0yTLFn91BUxDLw0qenYQhABEQCTBB/To8SNDjxzb6zh2985tfba6CAFgoD/3icfvunPv3PdeOn15vV5GnaNe1a3revt7riGGQeB77gjgDaaeSFuYQsGBNd7qptr0idvZ+owIAcIgiMOgE9ag7iN00dSINEq8gj26W/qfNkR3b7cev/vg9onmVydtGj0gQgBgjN2xe1viFX8gOl7wsTZpmiRJ0omS3+oGung9004AyONq1WjjIDK/pBVn+ciu63pGDHyv7SV4UnjdNoMA9QZ8InUwOjJpPnJk7+5to1stCroavXGWkmKhEIWrLjXYnIazREKu9237W19wHvre8sMiIot8feka4sauDuNAz08lBx5epkH03UqaxG2/USREFIVEois7+Nab2RBRVpQ+cffgHRO5bePDXWmk3TS9JMIkSfoHBm7dDk2+jH0/INSAaR1acX8DRkYz9PZGiBDRj0UliAWvhdoZaktLephq5vDGnHDB/fys50d1E8o0XnIDMLNae3WCkCYpmGQYmdYP1jBERCRSnUHGtuXDwDm/Z//Ep598cGlp86oa2wXm8/mmv7zJ7QA8zysUCgAwNDh4wzUgxnE8l1+YW3IXykHFj90w4YQADPFmpaQtOE66TDERMIaIbENx2kbSG30DQ7aTue58ImISsdK8rm34tUJ2VvSNXr9exDDwK6WNrbtrwJ1DIiEE3RruacN9Xj4MgCBCEoaGOccYzFgjA87kSP/o6IhWeyNnstmxsbHutmtpjpZciK15wUIIzrkQtGIEc2RkpOlxFxcXm/7uuuMSSE/x5ko9QGxmXKrmCevjImx4L+mOXu9Gx5W/TcZw7blAt4TUyri95I42CGNsjQZNtt18NxHLaj4e08q4fgvjZpzmNznp1vW2Mm4vsnWT9QrFuwQlQoWiyygRKhRdRolQoegySoQKRZdRIlQouowSoULRZZQIFYouo0SoUHQZJUKFossoESoUXUaJUKHoMkqECkWXUSJUKLqMEqFC0WWUCBWKLqNEqFB0GSVChaLL6FuzT4waV4377hlXWUKFossoESoUXUaJUKHoMkqECkWXUSJUKLqMEqFC0WWUCBWKLqNEqFB0GSVChaLLKBEqFF1GiVCh6DJKhApFl1EiVCi6jBKhQtFllAgVii6jRKhQdBklQoWiyygRKhRdRolQoegy/z8/PtLNdOeYdAAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAAASUVORK5CYII=');
INSERT INTO `users` VALUES (3, '2021001', '张三', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138001', 'zhangsan@example.com', 'STUDENT', 3, 3, '不吃牛肉，不吃海鲜', '2025-11-17 17:16:18', '2026-02-02 11:25:44', NULL, 80, 'active', 'data:image/png;base64,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');
INSERT INTO `users` VALUES (4, '2021002', '李四', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138002', 'lisi@example.com', 'STUDENT', 4, 2, '', '2025-11-17 17:16:18', '2025-12-16 14:03:50', NULL, NULL, '', NULL);
INSERT INTO `users` VALUES (5, '2021003', '王五', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138003', 'wangwu@example.com', 'STUDENT', 1, 3, '不吃辣', '2025-11-20 11:00:17', '2026-02-02 22:11:02', NULL, NULL, 'active', '/default-avatar.png');
INSERT INTO `users` VALUES (7, '2021005', '孙七', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138005', 'sunqi@example.com', 'STUDENT', 2, 1, '不吃油腻食物', '2025-11-20 11:00:17', '2026-01-14 13:52:08', NULL, 10, '', NULL);
INSERT INTO `users` VALUES (8, '2021006', '周八', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138006', 'zhouba@example.com', 'STUDENT', 3, 2, '不吃海鲜', '2025-11-20 11:00:17', '2026-02-02 22:10:31', NULL, NULL, 'active', '/default-avatar.png');
INSERT INTO `users` VALUES (9, '2021007', '吴九', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138007', 'wujiu@example.com', 'STUDENT', 2, 3, '不吃香菜，不吃葱', '2025-11-20 11:00:17', '2026-02-02 22:11:17', NULL, NULL, 'active', '/default-avatar.png');
INSERT INTO `users` VALUES (10, '2021008', '郑十', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138008', 'zhengshi@example.com', 'STUDENT', 4, 1, '素食主义', '2025-11-20 11:00:17', '2026-02-02 22:11:12', NULL, NULL, 'active', '/default-avatar.png');
INSERT INTO `users` VALUES (11, '2021009', '钱一', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138009', 'qianyi@example.com', 'STUDENT', 5, 1, '不吃蒜', '2025-11-20 11:00:17', '2026-02-02 22:10:51', NULL, NULL, 'active', '/default-avatar.png');
INSERT INTO `users` VALUES (12, '2021010', '孙二', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '17817171348', '3198035651@qq.com', 'STUDENT', 3, 5, '不吃羊肉', '2025-11-20 11:00:17', '2026-02-02 22:11:22', NULL, NULL, 'active', '/default-avatar.png');
INSERT INTO `users` VALUES (25, '2024001', 'teststudent', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138000', 'teststudent@example.com', 'STUDENT', 3, 3, NULL, '2026-03-11 11:28:41', '2026-03-11 11:28:41', NULL, 20, 'active', NULL);
INSERT INTO `users` VALUES (26, 'test001', 'testuser', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', NULL, 'test@example.com', 'STUDENT', 3, 3, NULL, '2026-03-11 11:35:45', '2026-03-11 11:35:45', NULL, 0, 'active', NULL);
INSERT INTO `users` VALUES (27, '2024010001', '测试用户', '$2a$10$flT/UdZ.dZdoY0cjSbWEJ.nW40F9dmS0xKnev9fNPUFr2EONM0bTW', '13800138000', 'test@example.com', 'STUDENT', 3, 3, NULL, '2026-03-12 11:05:12', '2026-03-12 11:05:12', NULL, 0, 'active', NULL);

-- ----------------------------
-- Table structure for windows
-- ----------------------------
DROP TABLE IF EXISTS `windows`;
CREATE TABLE `windows`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `canteen_id` bigint NULL DEFAULT NULL,
  `canteen_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `manager_id` bigint NULL DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `operating_hours` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` enum('CLOSED','MAINTENANCE','OPEN') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `update_time` datetime(6) NULL DEFAULT NULL,
  `manager_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of windows
-- ----------------------------
INSERT INTO `windows` VALUES (1, 1, '第一食堂', '2026-01-06 13:10:50.649357', '一楼东侧', NULL, '上海菜窗口', '08:00-18:00', 'OPEN', '2026-02-10 15:23:07.122626', '红姐');
INSERT INTO `windows` VALUES (2, 1, '第一食堂', '2026-01-06 13:10:50.680724', '三楼东侧', NULL, '川菜窗口', '08:00-18:00', 'OPEN', '2026-02-10 15:23:12.172170', '张姐');
INSERT INTO `windows` VALUES (3, 1, '第一食堂', '2026-01-06 13:10:50.686833', '一楼东侧', NULL, '早餐窗口', '06:30-10:30', 'OPEN', '2026-01-06 13:10:50.686833', NULL);
INSERT INTO `windows` VALUES (4, 1, '第一食堂', '2026-01-06 13:10:50.692955', '二楼东侧', NULL, '浙菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.692955', NULL);
INSERT INTO `windows` VALUES (5, 1, '第一食堂', '2026-01-06 13:10:50.697790', '一楼东侧', NULL, '湘菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.697790', NULL);
INSERT INTO `windows` VALUES (6, 1, '第一食堂', '2026-01-06 13:10:50.702352', '二楼东侧', NULL, '特色菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.702352', NULL);
INSERT INTO `windows` VALUES (7, 1, '第一食堂', '2026-01-06 13:10:50.706917', '三楼东侧', NULL, '甜品窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.706917', NULL);
INSERT INTO `windows` VALUES (8, 1, '第一食堂', '2026-01-06 13:10:50.713188', '三楼东侧', NULL, '粤菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.713188', NULL);
INSERT INTO `windows` VALUES (9, 1, '第一食堂', '2026-01-06 13:10:50.717793', '二楼东侧', NULL, '面食窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.717793', NULL);
INSERT INTO `windows` VALUES (10, 1, '第一食堂', '2026-01-06 13:10:50.723919', '一楼东侧', NULL, '鲁菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.723919', NULL);
INSERT INTO `windows` VALUES (11, 2, '第二食堂', '2026-01-06 13:10:50.728345', '二楼西侧', NULL, '上海菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.728345', NULL);
INSERT INTO `windows` VALUES (12, 2, '第二食堂', '2026-01-06 13:10:50.731394', '一楼西侧', NULL, '川菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.731394', NULL);
INSERT INTO `windows` VALUES (13, 2, '第二食堂', '2026-01-06 13:10:50.737642', '一楼西侧', NULL, '早餐窗口', '06:30-10:30', 'OPEN', '2026-01-06 13:10:50.737642', NULL);
INSERT INTO `windows` VALUES (14, 2, '第二食堂', '2026-01-06 13:10:50.742372', '一楼西侧', NULL, '湘菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.742372', NULL);
INSERT INTO `windows` VALUES (15, 2, '第二食堂', '2026-01-06 13:10:50.745455', '二楼西侧', NULL, '特色菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.745455', NULL);
INSERT INTO `windows` VALUES (16, 2, '第二食堂', '2026-01-06 13:10:50.750018', '三楼西侧', NULL, '盖浇饭窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.750018', NULL);
INSERT INTO `windows` VALUES (17, 2, '第二食堂', '2026-01-06 13:10:50.754571', '二楼西侧', NULL, '粤菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.754571', NULL);
INSERT INTO `windows` VALUES (18, 2, '第二食堂', '2026-01-06 13:10:50.759352', '二楼西侧', NULL, '苏菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.759352', NULL);
INSERT INTO `windows` VALUES (20, 3, '第三食堂', '2026-01-06 13:10:50.771726', '一楼南侧', NULL, '川菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.771726', NULL);
INSERT INTO `windows` VALUES (21, 3, '第三食堂', '2026-01-06 13:10:50.778538', '二楼南侧', NULL, '汤品窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.778538', NULL);
INSERT INTO `windows` VALUES (22, 3, '第三食堂', '2026-01-06 13:10:50.784660', '一楼南侧', NULL, '浙菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.784660', NULL);
INSERT INTO `windows` VALUES (23, 3, '第三食堂', '2026-01-06 13:10:50.792516', '三楼南侧', NULL, '清真窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.792516', NULL);
INSERT INTO `windows` VALUES (24, 3, '第三食堂', '2026-01-06 13:10:50.800275', '三楼南侧', NULL, '湘菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.800275', NULL);
INSERT INTO `windows` VALUES (25, 3, '第三食堂', '2026-01-06 13:10:50.808041', '三楼南侧', NULL, '特色菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.808041', NULL);
INSERT INTO `windows` VALUES (26, 3, '第三食堂', '2026-01-06 13:10:50.815710', '二楼南侧', NULL, '粤菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.815710', NULL);
INSERT INTO `windows` VALUES (27, 3, '第三食堂', '2026-01-06 13:10:50.820493', '二楼南侧', NULL, '苏菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.820493', NULL);

SET FOREIGN_KEY_CHECKS = 1;
