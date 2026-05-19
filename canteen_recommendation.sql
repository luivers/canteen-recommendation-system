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

 Date: 13/05/2026 22:29:20
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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
  `dish_id` bigint NULL DEFAULT NULL,
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
) ENGINE = InnoDB AUTO_INCREMENT = 336 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 905 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `daily_dish_statistics` VALUES (342, 'NORMAL', NULL, '2026-03-25 21:19:30.175332', 0, '2026-03-24', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (343, 'NORMAL', NULL, '2026-03-25 21:19:30.197464', 100, '2026-03-24', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (344, 'NORMAL', NULL, '2026-03-25 21:19:30.200866', 100, '2026-03-24', 3, '麻婆豆腐', 98, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (345, 'NORMAL', NULL, '2026-03-25 21:19:30.201790', 100, '2026-03-24', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (346, 'NORMAL', NULL, '2026-03-25 21:19:30.204016', 100, '2026-03-24', 5, '青椒土豆丝', 98, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (347, 'NORMAL', NULL, '2026-03-25 21:19:30.206460', 100, '2026-03-24', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (348, 'NORMAL', NULL, '2026-03-25 21:19:30.214829', 59, '2026-03-24', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (349, 'NORMAL', NULL, '2026-03-25 21:19:30.218593', 73, '2026-03-24', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (350, 'NORMAL', NULL, '2026-03-25 21:19:30.219609', 0, '2026-03-24', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (351, 'NORMAL', NULL, '2026-03-25 21:19:30.222180', 185, '2026-03-24', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (352, 'NORMAL', NULL, '2026-03-25 21:19:30.224329', 149, '2026-03-24', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (353, 'NORMAL', NULL, '2026-03-25 21:19:30.226563', 163, '2026-03-24', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (354, 'NORMAL', NULL, '2026-03-25 21:19:30.228804', 186, '2026-03-24', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (355, 'NORMAL', NULL, '2026-03-25 21:19:30.231771', 188, '2026-03-24', 14, '广东菜心', 186, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (356, 'NORMAL', NULL, '2026-03-25 21:19:30.233316', 199, '2026-03-24', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (357, 'NORMAL', NULL, '2026-03-25 21:19:30.235556', 174, '2026-03-24', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (358, 'NORMAL', NULL, '2026-03-25 21:19:30.236083', 69, '2026-03-24', 18, '葱爆羊肉', 69, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (359, 'NORMAL', NULL, '2026-03-25 21:19:30.239339', 63, '2026-03-24', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (360, 'NORMAL', NULL, '2026-03-25 21:19:30.240901', 108, '2026-03-24', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (361, 'NORMAL', NULL, '2026-03-25 21:19:30.243279', 161, '2026-03-24', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (362, 'NORMAL', NULL, '2026-03-25 21:19:30.245654', 65, '2026-03-24', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (363, 'NORMAL', NULL, '2026-03-25 21:19:30.247206', 0, '2026-03-24', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (364, 'NORMAL', NULL, '2026-03-25 21:19:30.248864', 57, '2026-03-24', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (365, 'NORMAL', NULL, '2026-03-25 21:19:30.250483', 0, '2026-03-24', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (366, 'NORMAL', NULL, '2026-03-25 21:19:30.252043', 133, '2026-03-24', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (367, 'NORMAL', NULL, '2026-03-25 21:19:30.254503', 127, '2026-03-24', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (368, 'NORMAL', NULL, '2026-03-25 21:19:30.257609', 92, '2026-03-24', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (369, 'NORMAL', NULL, '2026-03-25 21:19:30.259680', 166, '2026-03-24', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (370, 'NORMAL', NULL, '2026-03-25 21:19:30.262400', 148, '2026-03-24', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (371, 'NORMAL', NULL, '2026-03-25 21:19:30.263996', 116, '2026-03-24', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (372, 'NORMAL', NULL, '2026-03-25 21:19:30.267320', 119, '2026-03-24', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (373, 'NORMAL', NULL, '2026-03-26 22:12:22.837392', 0, '2026-03-25', 1, '红烧肉', 58, 60, 118);
INSERT INTO `daily_dish_statistics` VALUES (374, 'NORMAL', NULL, '2026-03-26 22:12:22.851776', 100, '2026-03-25', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (375, 'NORMAL', NULL, '2026-03-26 22:12:22.853332', 100, '2026-03-25', 3, '麻婆豆腐', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (376, 'NORMAL', NULL, '2026-03-26 22:12:22.856194', 100, '2026-03-25', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (377, 'NORMAL', NULL, '2026-03-26 22:12:22.856194', 100, '2026-03-25', 5, '青椒土豆丝', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (378, 'NORMAL', NULL, '2026-03-26 22:12:22.859203', 100, '2026-03-25', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (379, 'NORMAL', NULL, '2026-03-26 22:12:22.865368', 59, '2026-03-25', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (380, 'NORMAL', NULL, '2026-03-26 22:12:22.866383', 73, '2026-03-25', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (381, 'NORMAL', NULL, '2026-03-26 22:12:22.867955', 0, '2026-03-25', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (382, 'NORMAL', NULL, '2026-03-26 22:12:22.869550', 185, '2026-03-25', 10, '包子', 184, 1, 185);
INSERT INTO `daily_dish_statistics` VALUES (383, 'NORMAL', NULL, '2026-03-26 22:12:22.873034', 149, '2026-03-25', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (384, 'NORMAL', NULL, '2026-03-26 22:12:22.874562', 163, '2026-03-25', 12, '回锅肉', 162, 1, 163);
INSERT INTO `daily_dish_statistics` VALUES (385, 'NORMAL', NULL, '2026-03-26 22:12:22.875937', 186, '2026-03-25', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (386, 'NORMAL', NULL, '2026-03-26 22:12:22.876450', 188, '2026-03-25', 14, '广东菜心', 187, 1, 188);
INSERT INTO `daily_dish_statistics` VALUES (387, 'NORMAL', NULL, '2026-03-26 22:12:22.878541', 199, '2026-03-25', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (388, 'NORMAL', NULL, '2026-03-26 22:12:22.880757', 174, '2026-03-25', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (389, 'CRITICAL', '库存极低（剩余 0 份），请立即补货', '2026-03-26 22:12:22.881809', 69, '2026-03-25', 18, '葱爆羊肉', 0, 69, 69);
INSERT INTO `daily_dish_statistics` VALUES (390, 'NORMAL', NULL, '2026-03-26 22:12:22.884376', 63, '2026-03-25', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (391, 'NORMAL', NULL, '2026-03-26 22:12:22.911015', 108, '2026-03-25', 21, '清炒时蔬', 106, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (392, 'NORMAL', NULL, '2026-03-26 22:12:22.913085', 161, '2026-03-25', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (393, 'NORMAL', NULL, '2026-03-26 22:12:22.915432', 65, '2026-03-25', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (394, 'NORMAL', NULL, '2026-03-26 22:12:22.918205', 0, '2026-03-25', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (395, 'NORMAL', NULL, '2026-03-26 22:12:22.921921', 57, '2026-03-25', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (396, 'NORMAL', NULL, '2026-03-26 22:12:22.928209', 0, '2026-03-25', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (397, 'NORMAL', NULL, '2026-03-26 22:12:22.929234', 133, '2026-03-25', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (398, 'NORMAL', NULL, '2026-03-26 22:12:22.930828', 127, '2026-03-25', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (399, 'NORMAL', NULL, '2026-03-26 22:12:22.934781', 92, '2026-03-25', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (400, 'NORMAL', NULL, '2026-03-26 22:12:22.936162', 166, '2026-03-25', 30, '西湖醋鱼', 165, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (401, 'NORMAL', NULL, '2026-03-26 22:12:22.936675', 148, '2026-03-25', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (402, 'NORMAL', NULL, '2026-03-26 22:12:22.941034', 116, '2026-03-25', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (403, 'NORMAL', NULL, '2026-03-26 22:12:22.946064', 119, '2026-03-25', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (404, 'NORMAL', NULL, '2026-03-27 09:55:33.211678', 0, '2026-03-26', 1, '红烧肉', 58, 0, 58);
INSERT INTO `daily_dish_statistics` VALUES (405, 'NORMAL', NULL, '2026-03-27 09:55:33.248548', 100, '2026-03-26', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (406, 'NORMAL', NULL, '2026-03-27 09:55:33.251492', 100, '2026-03-26', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (407, 'NORMAL', NULL, '2026-03-27 09:55:33.252759', 100, '2026-03-26', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (408, 'NORMAL', NULL, '2026-03-27 09:55:33.254207', 100, '2026-03-26', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (409, 'NORMAL', NULL, '2026-03-27 09:55:33.258858', 100, '2026-03-26', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (410, 'NORMAL', NULL, '2026-03-27 09:55:33.264542', 59, '2026-03-26', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (411, 'NORMAL', NULL, '2026-03-27 09:55:33.266946', 73, '2026-03-26', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (412, 'NORMAL', NULL, '2026-03-27 09:55:33.270437', 0, '2026-03-26', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (413, 'NORMAL', NULL, '2026-03-27 09:55:33.272405', 185, '2026-03-26', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (414, 'NORMAL', NULL, '2026-03-27 09:55:33.277262', 149, '2026-03-26', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (415, 'NORMAL', NULL, '2026-03-27 09:55:33.279492', 163, '2026-03-26', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (416, 'NORMAL', NULL, '2026-03-27 09:55:33.282108', 186, '2026-03-26', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (417, 'NORMAL', NULL, '2026-03-27 09:55:33.284940', 188, '2026-03-26', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (418, 'NORMAL', NULL, '2026-03-27 09:55:33.288884', 199, '2026-03-26', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (419, 'NORMAL', NULL, '2026-03-27 09:55:33.290740', 174, '2026-03-26', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (420, 'CRITICAL', '库存极低（剩余 0 份），请立即补货', '2026-03-27 09:55:33.293277', 69, '2026-03-26', 18, '葱爆羊肉', 0, 0, 69);
INSERT INTO `daily_dish_statistics` VALUES (421, 'NORMAL', NULL, '2026-03-27 09:55:33.296312', 63, '2026-03-26', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (422, 'NORMAL', NULL, '2026-03-27 09:55:33.298319', 108, '2026-03-26', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (423, 'NORMAL', NULL, '2026-03-27 09:55:33.299578', 161, '2026-03-26', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (424, 'NORMAL', NULL, '2026-03-27 09:55:33.301188', 65, '2026-03-26', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (425, 'NORMAL', NULL, '2026-03-27 09:55:33.303588', 0, '2026-03-26', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (426, 'NORMAL', NULL, '2026-03-27 09:55:33.304458', 57, '2026-03-26', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (427, 'NORMAL', NULL, '2026-03-27 09:55:33.308418', 0, '2026-03-26', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (428, 'NORMAL', NULL, '2026-03-27 09:55:33.309778', 133, '2026-03-26', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (429, 'NORMAL', NULL, '2026-03-27 09:55:33.313197', 127, '2026-03-26', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (430, 'NORMAL', NULL, '2026-03-27 09:55:33.315747', 92, '2026-03-26', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (431, 'NORMAL', NULL, '2026-03-27 09:55:33.317193', 166, '2026-03-26', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (432, 'NORMAL', NULL, '2026-03-27 09:55:33.319339', 148, '2026-03-26', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (433, 'NORMAL', NULL, '2026-03-27 09:55:33.320967', 116, '2026-03-26', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (434, 'NORMAL', NULL, '2026-03-27 09:55:33.324105', 119, '2026-03-26', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (435, 'NORMAL', NULL, '2026-03-28 19:52:26.517321', 100, '2026-03-27', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (436, 'NORMAL', NULL, '2026-03-28 19:52:26.529431', 100, '2026-03-27', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (437, 'NORMAL', NULL, '2026-03-28 19:52:26.531949', 100, '2026-03-27', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (438, 'NORMAL', NULL, '2026-03-28 19:52:26.535226', 100, '2026-03-27', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (439, 'NORMAL', NULL, '2026-03-28 19:52:26.543295', 100, '2026-03-27', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (440, 'NORMAL', NULL, '2026-03-28 19:52:26.544971', 100, '2026-03-27', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (441, 'NORMAL', NULL, '2026-03-28 19:52:26.544971', 59, '2026-03-27', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (442, 'NORMAL', NULL, '2026-03-28 19:52:26.546493', 73, '2026-03-27', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (443, 'NORMAL', NULL, '2026-03-28 19:52:26.548013', 0, '2026-03-27', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (444, 'NORMAL', NULL, '2026-03-28 19:52:26.550744', 185, '2026-03-27', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (445, 'NORMAL', NULL, '2026-03-28 19:52:26.552295', 149, '2026-03-27', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (446, 'NORMAL', NULL, '2026-03-28 19:52:26.553834', 163, '2026-03-27', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (447, 'NORMAL', NULL, '2026-03-28 19:52:26.557829', 186, '2026-03-27', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (448, 'NORMAL', NULL, '2026-03-28 19:52:26.560380', 188, '2026-03-27', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (449, 'NORMAL', NULL, '2026-03-28 19:52:26.562394', 199, '2026-03-27', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (450, 'NORMAL', NULL, '2026-03-28 19:52:26.564532', 174, '2026-03-27', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (451, 'NORMAL', NULL, '2026-03-28 19:52:26.566041', 0, '2026-03-27', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (452, 'NORMAL', NULL, '2026-03-28 19:52:26.566558', 63, '2026-03-27', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (453, 'NORMAL', NULL, '2026-03-28 19:52:26.568109', 108, '2026-03-27', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (454, 'NORMAL', NULL, '2026-03-28 19:52:26.569622', 161, '2026-03-27', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (455, 'NORMAL', NULL, '2026-03-28 19:52:26.571915', 65, '2026-03-27', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (456, 'NORMAL', NULL, '2026-03-28 19:52:26.573480', 0, '2026-03-27', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (457, 'NORMAL', NULL, '2026-03-28 19:52:26.576542', 57, '2026-03-27', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (458, 'NORMAL', NULL, '2026-03-28 19:52:26.584226', 0, '2026-03-27', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (459, 'NORMAL', NULL, '2026-03-28 19:52:26.587433', 133, '2026-03-27', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (460, 'NORMAL', NULL, '2026-03-28 19:52:26.590656', 127, '2026-03-27', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (461, 'NORMAL', NULL, '2026-03-28 19:52:26.593996', 92, '2026-03-27', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (462, 'NORMAL', NULL, '2026-03-28 19:52:26.595550', 166, '2026-03-27', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (463, 'NORMAL', NULL, '2026-03-28 19:52:26.601029', 148, '2026-03-27', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (464, 'NORMAL', NULL, '2026-03-28 19:52:26.603400', 116, '2026-03-27', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (465, 'NORMAL', NULL, '2026-03-28 19:52:26.605044', 119, '2026-03-27', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (466, 'NORMAL', NULL, '2026-03-30 10:15:30.928993', 100, '2026-03-29', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (467, 'NORMAL', NULL, '2026-03-30 10:15:30.951291', 100, '2026-03-29', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (468, 'NORMAL', NULL, '2026-03-30 10:15:30.954117', 100, '2026-03-29', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (469, 'NORMAL', NULL, '2026-03-30 10:15:30.956752', 100, '2026-03-29', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (470, 'NORMAL', NULL, '2026-03-30 10:15:30.958789', 100, '2026-03-29', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (471, 'NORMAL', NULL, '2026-03-30 10:15:30.962966', 100, '2026-03-29', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (472, 'NORMAL', NULL, '2026-03-30 10:15:30.966700', 59, '2026-03-29', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (473, 'NORMAL', NULL, '2026-03-30 10:15:30.969980', 73, '2026-03-29', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (474, 'NORMAL', NULL, '2026-03-30 10:15:30.974092', 0, '2026-03-29', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (475, 'NORMAL', NULL, '2026-03-30 10:15:30.976891', 185, '2026-03-29', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (476, 'NORMAL', NULL, '2026-03-30 10:15:30.978404', 149, '2026-03-29', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (477, 'NORMAL', NULL, '2026-03-30 10:15:30.980462', 163, '2026-03-29', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (478, 'NORMAL', NULL, '2026-03-30 10:15:30.982858', 186, '2026-03-29', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (479, 'NORMAL', NULL, '2026-03-30 10:15:30.984019', 188, '2026-03-29', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (480, 'NORMAL', NULL, '2026-03-30 10:15:30.987051', 199, '2026-03-29', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (481, 'NORMAL', NULL, '2026-03-30 10:15:30.988656', 174, '2026-03-29', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (482, 'NORMAL', NULL, '2026-03-30 10:15:30.991394', 0, '2026-03-29', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (483, 'NORMAL', NULL, '2026-03-30 10:15:30.993591', 63, '2026-03-29', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (484, 'NORMAL', NULL, '2026-03-30 10:15:30.995432', 108, '2026-03-29', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (485, 'NORMAL', NULL, '2026-03-30 10:15:30.997805', 161, '2026-03-29', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (486, 'WARNING', '库存紧张（剩余 15 份），请注意补货', '2026-03-30 10:15:30.999594', 65, '2026-03-29', 23, '小笼包', 15, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (487, 'NORMAL', NULL, '2026-03-30 10:15:31.001288', 0, '2026-03-29', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (488, 'NORMAL', NULL, '2026-03-30 10:15:31.004083', 57, '2026-03-29', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (489, 'NORMAL', NULL, '2026-03-30 10:15:31.006134', 0, '2026-03-29', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (490, 'NORMAL', NULL, '2026-03-30 10:15:31.007233', 133, '2026-03-29', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (491, 'NORMAL', NULL, '2026-03-30 10:15:31.010319', 127, '2026-03-29', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (492, 'NORMAL', NULL, '2026-03-30 10:15:31.013344', 92, '2026-03-29', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (493, 'NORMAL', NULL, '2026-03-30 10:15:31.015837', 166, '2026-03-29', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (494, 'NORMAL', NULL, '2026-03-30 10:15:31.017800', 148, '2026-03-29', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (495, 'NORMAL', NULL, '2026-03-30 10:15:31.020574', 116, '2026-03-29', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (496, 'NORMAL', NULL, '2026-03-30 10:15:31.022555', 119, '2026-03-29', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (497, 'NORMAL', NULL, '2026-04-04 13:35:23.347948', 100, '2026-04-03', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (498, 'NORMAL', NULL, '2026-04-04 13:35:23.389553', 100, '2026-04-03', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (499, 'NORMAL', NULL, '2026-04-04 13:35:23.392176', 100, '2026-04-03', 3, '麻婆豆腐', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (500, 'NORMAL', NULL, '2026-04-04 13:35:23.393808', 100, '2026-04-03', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (501, 'NORMAL', NULL, '2026-04-04 13:35:23.399735', 100, '2026-04-03', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (502, 'NORMAL', NULL, '2026-04-04 13:35:23.405299', 100, '2026-04-03', 6, '紫菜蛋花汤', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (503, 'NORMAL', NULL, '2026-04-04 13:35:23.411949', 59, '2026-04-03', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (504, 'NORMAL', NULL, '2026-04-04 13:35:23.414779', 73, '2026-04-03', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (505, 'NORMAL', NULL, '2026-04-04 13:35:23.415785', 0, '2026-04-03', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (506, 'NORMAL', NULL, '2026-04-04 13:35:23.417368', 185, '2026-04-03', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (507, 'NORMAL', NULL, '2026-04-04 13:35:23.417368', 149, '2026-04-03', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (508, 'NORMAL', NULL, '2026-04-04 13:35:23.419027', 163, '2026-04-03', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (509, 'NORMAL', NULL, '2026-04-04 13:35:23.426516', 186, '2026-04-03', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (510, 'NORMAL', NULL, '2026-04-04 13:35:23.428554', 188, '2026-04-03', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (511, 'NORMAL', NULL, '2026-04-04 13:35:23.430551', 199, '2026-04-03', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (512, 'NORMAL', NULL, '2026-04-04 13:35:23.431651', 174, '2026-04-03', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (513, 'NORMAL', NULL, '2026-04-04 13:35:23.438506', 0, '2026-04-03', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (514, 'NORMAL', NULL, '2026-04-04 13:35:23.440934', 63, '2026-04-03', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (515, 'NORMAL', NULL, '2026-04-04 13:35:23.442884', 108, '2026-04-03', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (516, 'NORMAL', NULL, '2026-04-04 13:35:23.444408', 161, '2026-04-03', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (517, 'NORMAL', NULL, '2026-04-04 13:35:23.446826', 65, '2026-04-03', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (518, 'NORMAL', NULL, '2026-04-04 13:35:23.449909', 0, '2026-04-03', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (519, 'NORMAL', NULL, '2026-04-04 13:35:23.453426', 57, '2026-04-03', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (520, 'NORMAL', NULL, '2026-04-04 13:35:23.455828', 0, '2026-04-03', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (521, 'NORMAL', NULL, '2026-04-04 13:35:23.457409', 133, '2026-04-03', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (522, 'NORMAL', NULL, '2026-04-04 13:35:23.458416', 127, '2026-04-03', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (523, 'NORMAL', NULL, '2026-04-04 13:35:23.461036', 92, '2026-04-03', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (524, 'NORMAL', NULL, '2026-04-04 13:35:23.463096', 166, '2026-04-03', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (525, 'NORMAL', NULL, '2026-04-04 13:35:23.465132', 148, '2026-04-03', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (526, 'NORMAL', NULL, '2026-04-04 13:35:23.466145', 116, '2026-04-03', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (527, 'NORMAL', NULL, '2026-04-04 13:35:23.468142', 119, '2026-04-03', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (528, 'NORMAL', NULL, '2026-04-07 15:55:13.897546', 100, '2026-04-06', 1, '红烧肉', 97, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (529, 'NORMAL', NULL, '2026-04-07 15:55:13.925307', 100, '2026-04-06', 2, '宫保鸡丁', 98, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (530, 'NORMAL', NULL, '2026-04-07 15:55:13.928815', 100, '2026-04-06', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (531, 'NORMAL', NULL, '2026-04-07 15:55:13.929983', 100, '2026-04-06', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (532, 'NORMAL', NULL, '2026-04-07 15:55:13.933202', 100, '2026-04-06', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (533, 'NORMAL', NULL, '2026-04-07 15:55:13.934797', 100, '2026-04-06', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (534, 'NORMAL', NULL, '2026-04-07 15:55:13.936954', 59, '2026-04-06', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (535, 'NORMAL', NULL, '2026-04-07 15:55:13.937960', 73, '2026-04-06', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (536, 'NORMAL', NULL, '2026-04-07 15:55:13.939806', 0, '2026-04-06', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (537, 'NORMAL', NULL, '2026-04-07 15:55:13.942872', 185, '2026-04-06', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (538, 'NORMAL', NULL, '2026-04-07 15:55:13.946420', 149, '2026-04-06', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (539, 'NORMAL', NULL, '2026-04-07 15:55:13.950315', 163, '2026-04-06', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (540, 'NORMAL', NULL, '2026-04-07 15:55:13.953369', 186, '2026-04-06', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (541, 'NORMAL', NULL, '2026-04-07 15:55:13.956450', 188, '2026-04-06', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (542, 'NORMAL', NULL, '2026-04-07 15:55:13.958859', 199, '2026-04-06', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (543, 'NORMAL', NULL, '2026-04-07 15:55:13.961890', 174, '2026-04-06', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (544, 'NORMAL', NULL, '2026-04-07 15:55:13.964616', 0, '2026-04-06', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (545, 'NORMAL', NULL, '2026-04-07 15:55:13.967637', 63, '2026-04-06', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (546, 'NORMAL', NULL, '2026-04-07 15:55:13.969707', 108, '2026-04-06', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (547, 'NORMAL', NULL, '2026-04-07 15:55:13.971239', 161, '2026-04-06', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (548, 'NORMAL', NULL, '2026-04-07 15:55:13.974343', 65, '2026-04-06', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (549, 'NORMAL', NULL, '2026-04-07 15:55:13.975872', 0, '2026-04-06', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (550, 'NORMAL', NULL, '2026-04-07 15:55:13.979031', 57, '2026-04-06', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (551, 'NORMAL', NULL, '2026-04-07 15:55:13.981693', 0, '2026-04-06', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (552, 'NORMAL', NULL, '2026-04-07 15:55:13.984235', 133, '2026-04-06', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (553, 'NORMAL', NULL, '2026-04-07 15:55:13.985822', 127, '2026-04-06', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (554, 'NORMAL', NULL, '2026-04-07 15:55:13.987350', 92, '2026-04-06', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (555, 'NORMAL', NULL, '2026-04-07 15:55:13.990537', 166, '2026-04-06', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (556, 'NORMAL', NULL, '2026-04-07 15:55:13.992060', 148, '2026-04-06', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (557, 'NORMAL', NULL, '2026-04-07 15:55:13.993603', 116, '2026-04-06', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (558, 'NORMAL', NULL, '2026-04-07 15:55:13.996877', 119, '2026-04-06', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (559, 'NORMAL', NULL, '2026-04-07 15:55:13.998430', 0, '2026-04-06', 54, '广式肠粉', 50, 0, 50);
INSERT INTO `daily_dish_statistics` VALUES (560, 'NORMAL', NULL, '2026-04-08 11:48:06.015449', 100, '2026-04-07', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (561, 'NORMAL', NULL, '2026-04-08 11:48:06.026706', 100, '2026-04-07', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (562, 'NORMAL', NULL, '2026-04-08 11:48:06.027721', 100, '2026-04-07', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (563, 'NORMAL', NULL, '2026-04-08 11:48:06.029847', 100, '2026-04-07', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (564, 'NORMAL', NULL, '2026-04-08 11:48:06.030852', 100, '2026-04-07', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (565, 'NORMAL', NULL, '2026-04-08 11:48:06.032001', 100, '2026-04-07', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (566, 'NORMAL', NULL, '2026-04-08 11:48:06.032429', 59, '2026-04-07', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (567, 'NORMAL', NULL, '2026-04-08 11:48:06.034044', 73, '2026-04-07', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (568, 'NORMAL', NULL, '2026-04-08 11:48:06.035046', 0, '2026-04-07', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (569, 'NORMAL', NULL, '2026-04-08 11:48:06.035554', 185, '2026-04-07', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (570, 'NORMAL', NULL, '2026-04-08 11:48:06.036559', 149, '2026-04-07', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (571, 'NORMAL', NULL, '2026-04-08 11:48:06.040242', 163, '2026-04-07', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (572, 'NORMAL', NULL, '2026-04-08 11:48:06.042941', 186, '2026-04-07', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (573, 'NORMAL', NULL, '2026-04-08 11:48:06.043970', 188, '2026-04-07', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (574, 'NORMAL', NULL, '2026-04-08 11:48:06.045943', 199, '2026-04-07', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (575, 'NORMAL', NULL, '2026-04-08 11:48:06.055834', 174, '2026-04-07', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (576, 'NORMAL', NULL, '2026-04-08 11:48:06.057641', 0, '2026-04-07', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (577, 'NORMAL', NULL, '2026-04-08 11:48:06.064952', 63, '2026-04-07', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (578, 'NORMAL', NULL, '2026-04-08 11:48:06.067812', 108, '2026-04-07', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (579, 'NORMAL', NULL, '2026-04-08 11:48:06.069259', 161, '2026-04-07', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (580, 'NORMAL', NULL, '2026-04-08 11:48:06.073708', 65, '2026-04-07', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (581, 'NORMAL', NULL, '2026-04-08 11:48:06.076107', 0, '2026-04-07', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (582, 'NORMAL', NULL, '2026-04-08 11:48:06.077965', 57, '2026-04-07', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (583, 'NORMAL', NULL, '2026-04-08 11:48:06.081587', 0, '2026-04-07', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (584, 'NORMAL', NULL, '2026-04-08 11:48:06.084604', 133, '2026-04-07', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (585, 'NORMAL', NULL, '2026-04-08 11:48:06.102781', 127, '2026-04-07', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (586, 'NORMAL', NULL, '2026-04-08 11:48:06.104243', 92, '2026-04-07', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (587, 'NORMAL', NULL, '2026-04-08 11:48:06.105259', 166, '2026-04-07', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (588, 'NORMAL', NULL, '2026-04-08 11:48:06.110231', 148, '2026-04-07', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (589, 'NORMAL', NULL, '2026-04-08 11:48:06.110231', 116, '2026-04-07', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (590, 'NORMAL', NULL, '2026-04-08 11:48:06.112262', 119, '2026-04-07', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (591, 'NORMAL', NULL, '2026-04-08 11:48:06.113784', 0, '2026-04-07', 54, '广式肠粉', 50, 0, 50);
INSERT INTO `daily_dish_statistics` VALUES (592, 'NORMAL', NULL, '2026-04-19 23:14:07.524159', 100, '2026-04-18', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (593, 'NORMAL', NULL, '2026-04-19 23:14:07.550373', 100, '2026-04-18', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (594, 'NORMAL', NULL, '2026-04-19 23:14:07.552708', 100, '2026-04-18', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (595, 'NORMAL', NULL, '2026-04-19 23:14:07.557605', 100, '2026-04-18', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (596, 'NORMAL', NULL, '2026-04-19 23:14:07.560337', 100, '2026-04-18', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (597, 'NORMAL', NULL, '2026-04-19 23:14:07.561462', 100, '2026-04-18', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (598, 'NORMAL', NULL, '2026-04-19 23:14:07.565900', 59, '2026-04-18', 7, '鱼香肉丝', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (599, 'NORMAL', NULL, '2026-04-19 23:14:07.569650', 73, '2026-04-18', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (600, 'NORMAL', NULL, '2026-04-19 23:14:07.572700', 0, '2026-04-18', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (601, 'NORMAL', NULL, '2026-04-19 23:14:07.578315', 185, '2026-04-18', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (602, 'NORMAL', NULL, '2026-04-19 23:14:07.581102', 149, '2026-04-18', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (603, 'NORMAL', NULL, '2026-04-19 23:14:07.585406', 163, '2026-04-18', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (604, 'NORMAL', NULL, '2026-04-19 23:14:07.590977', 186, '2026-04-18', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (605, 'NORMAL', NULL, '2026-04-19 23:14:07.596562', 188, '2026-04-18', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (606, 'NORMAL', NULL, '2026-04-19 23:14:07.599286', 199, '2026-04-18', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (607, 'NORMAL', NULL, '2026-04-19 23:14:07.603819', 174, '2026-04-18', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (608, 'NORMAL', NULL, '2026-04-19 23:14:07.604857', 0, '2026-04-18', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (609, 'NORMAL', NULL, '2026-04-19 23:14:07.607604', 63, '2026-04-18', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (610, 'NORMAL', NULL, '2026-04-19 23:14:07.610379', 108, '2026-04-18', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (611, 'NORMAL', NULL, '2026-04-19 23:14:07.613144', 161, '2026-04-18', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (612, 'NORMAL', NULL, '2026-04-19 23:14:07.615308', 65, '2026-04-18', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (613, 'NORMAL', NULL, '2026-04-19 23:14:07.618666', 0, '2026-04-18', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (614, 'NORMAL', NULL, '2026-04-19 23:14:07.621437', 57, '2026-04-18', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (615, 'NORMAL', NULL, '2026-04-19 23:14:07.624657', 0, '2026-04-18', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (616, 'NORMAL', NULL, '2026-04-19 23:14:07.627227', 133, '2026-04-18', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (617, 'NORMAL', NULL, '2026-04-19 23:14:07.629882', 127, '2026-04-18', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (618, 'NORMAL', NULL, '2026-04-19 23:14:07.638154', 92, '2026-04-18', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (619, 'NORMAL', NULL, '2026-04-19 23:14:07.643600', 166, '2026-04-18', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (620, 'NORMAL', NULL, '2026-04-19 23:14:07.645802', 148, '2026-04-18', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (621, 'NORMAL', NULL, '2026-04-19 23:14:07.646813', 116, '2026-04-18', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (622, 'NORMAL', NULL, '2026-04-19 23:14:07.651062', 119, '2026-04-18', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (623, 'NORMAL', NULL, '2026-04-19 23:14:07.652764', 0, '2026-04-18', 56, '广式肠粉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (624, 'NORMAL', NULL, '2026-04-27 14:40:20.707825', 100, '2026-04-26', 1, '红烧肉', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (625, 'NORMAL', NULL, '2026-04-27 14:40:20.737653', 100, '2026-04-26', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (626, 'NORMAL', NULL, '2026-04-27 14:40:20.741016', 100, '2026-04-26', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (627, 'NORMAL', NULL, '2026-04-27 14:40:20.745383', 100, '2026-04-26', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (628, 'NORMAL', NULL, '2026-04-27 14:40:20.746037', 100, '2026-04-26', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (629, 'NORMAL', NULL, '2026-04-27 14:40:20.748806', 100, '2026-04-26', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (630, 'NORMAL', NULL, '2026-04-27 14:40:20.751529', 0, '2026-04-26', 7, '鱼香肉丝', 30, 0, 30);
INSERT INTO `daily_dish_statistics` VALUES (631, 'NORMAL', NULL, '2026-04-27 14:40:20.752659', 73, '2026-04-26', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (632, 'NORMAL', NULL, '2026-04-27 14:40:20.756172', 0, '2026-04-26', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (633, 'NORMAL', NULL, '2026-04-27 14:40:20.757916', 185, '2026-04-26', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (634, 'NORMAL', NULL, '2026-04-27 14:40:20.765396', 149, '2026-04-26', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (635, 'NORMAL', NULL, '2026-04-27 14:40:20.768952', 163, '2026-04-26', 12, '回锅肉', 162, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (636, 'NORMAL', NULL, '2026-04-27 14:40:20.768952', 186, '2026-04-26', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (637, 'NORMAL', NULL, '2026-04-27 14:40:20.774167', 188, '2026-04-26', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (638, 'NORMAL', NULL, '2026-04-27 14:40:20.776542', 199, '2026-04-26', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (639, 'NORMAL', NULL, '2026-04-27 14:40:20.777690', 174, '2026-04-26', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (640, 'NORMAL', NULL, '2026-04-27 14:40:20.781992', 0, '2026-04-26', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (641, 'NORMAL', NULL, '2026-04-27 14:40:20.782383', 63, '2026-04-26', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (642, 'NORMAL', NULL, '2026-04-27 14:40:20.786243', 108, '2026-04-26', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (643, 'NORMAL', NULL, '2026-04-27 14:40:20.789028', 161, '2026-04-26', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (644, 'NORMAL', NULL, '2026-04-27 14:40:20.790459', 65, '2026-04-26', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (645, 'NORMAL', NULL, '2026-04-27 14:40:20.793536', 0, '2026-04-26', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (646, 'NORMAL', NULL, '2026-04-27 14:40:20.795080', 57, '2026-04-26', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (647, 'NORMAL', NULL, '2026-04-27 14:40:20.796032', 0, '2026-04-26', 26, '扬州炒饭', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (648, 'NORMAL', NULL, '2026-04-27 14:40:20.799433', 133, '2026-04-26', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (649, 'NORMAL', NULL, '2026-04-27 14:40:20.801568', 127, '2026-04-26', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (650, 'NORMAL', NULL, '2026-04-27 14:40:20.805536', 92, '2026-04-26', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (651, 'NORMAL', NULL, '2026-04-27 14:40:20.807519', 166, '2026-04-26', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (652, 'NORMAL', NULL, '2026-04-27 14:40:20.810672', 148, '2026-04-26', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (653, 'NORMAL', NULL, '2026-04-27 14:40:20.812691', 116, '2026-04-26', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (654, 'NORMAL', NULL, '2026-04-27 14:40:20.812691', 119, '2026-04-26', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (655, 'NORMAL', NULL, '2026-04-27 14:40:20.816145', 0, '2026-04-26', 56, '广式肠粉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (656, 'NORMAL', NULL, '2026-04-28 11:14:40.992901', 0, '2026-04-27', 1, '红烧肉', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (657, 'NORMAL', NULL, '2026-04-28 11:14:41.019569', 100, '2026-04-27', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (658, 'NORMAL', NULL, '2026-04-28 11:14:41.023497', 100, '2026-04-27', 3, '麻婆豆腐', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (659, 'NORMAL', NULL, '2026-04-28 11:14:41.026836', 100, '2026-04-27', 4, '西红柿鸡蛋', 98, 2, 100);
INSERT INTO `daily_dish_statistics` VALUES (660, 'NORMAL', NULL, '2026-04-28 11:14:41.028835', 100, '2026-04-27', 5, '青椒土豆丝', 96, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (661, 'NORMAL', NULL, '2026-04-28 11:14:41.030443', 100, '2026-04-27', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (662, 'NORMAL', NULL, '2026-04-28 11:14:41.033513', 0, '2026-04-27', 7, '鱼香肉丝', 29, 1, 30);
INSERT INTO `daily_dish_statistics` VALUES (663, 'CRITICAL', '库存极低（剩余 3 份，销量已达剩余库存的80%），请立即补货', '2026-04-28 11:14:41.047897', 73, '2026-04-27', 8, '清蒸鱼', 3, 70, 73);
INSERT INTO `daily_dish_statistics` VALUES (664, 'NORMAL', NULL, '2026-04-28 11:14:41.047897', 0, '2026-04-27', 9, '清真牛肉饭', 110, 0, 110);
INSERT INTO `daily_dish_statistics` VALUES (665, 'NORMAL', NULL, '2026-04-28 11:14:41.050578', 185, '2026-04-27', 10, '包子', 185, 0, 185);
INSERT INTO `daily_dish_statistics` VALUES (666, 'NORMAL', NULL, '2026-04-28 11:14:41.052854', 149, '2026-04-27', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (667, 'NORMAL', NULL, '2026-04-28 11:14:41.053380', 163, '2026-04-27', 12, '回锅肉', 162, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (668, 'NORMAL', NULL, '2026-04-28 11:14:41.057031', 186, '2026-04-27', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (669, 'NORMAL', NULL, '2026-04-28 11:14:41.058899', 188, '2026-04-27', 14, '广东菜心', 186, 1, 188);
INSERT INTO `daily_dish_statistics` VALUES (670, 'NORMAL', NULL, '2026-04-28 11:14:41.059226', 199, '2026-04-27', 16, '烧腊饭', 199, 0, 199);
INSERT INTO `daily_dish_statistics` VALUES (671, 'NORMAL', NULL, '2026-04-28 11:14:41.061720', 174, '2026-04-27', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (672, 'NORMAL', NULL, '2026-04-28 11:14:41.064450', 0, '2026-04-27', 18, '葱爆羊肉', 60, 0, 60);
INSERT INTO `daily_dish_statistics` VALUES (673, 'NORMAL', NULL, '2026-04-28 11:14:41.066237', 63, '2026-04-27', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (674, 'NORMAL', NULL, '2026-04-28 11:14:41.067580', 108, '2026-04-27', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (675, 'NORMAL', NULL, '2026-04-28 11:14:41.070246', 161, '2026-04-27', 22, '西红柿鸡蛋面', 161, 0, 161);
INSERT INTO `daily_dish_statistics` VALUES (676, 'NORMAL', NULL, '2026-04-28 11:14:41.070246', 65, '2026-04-27', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (677, 'NORMAL', NULL, '2026-04-28 11:14:41.075637', 0, '2026-04-27', 24, '松鼠桂鱼', 159, 0, 159);
INSERT INTO `daily_dish_statistics` VALUES (678, 'NORMAL', NULL, '2026-04-28 11:14:41.076913', 57, '2026-04-27', 25, '清炒虾仁', 56, 1, 57);
INSERT INTO `daily_dish_statistics` VALUES (679, 'NORMAL', NULL, '2026-04-28 11:14:41.078403', 0, '2026-04-27', 26, '扬州炒饭', 183, 0, 183);
INSERT INTO `daily_dish_statistics` VALUES (680, 'NORMAL', NULL, '2026-04-28 11:14:41.081146', 133, '2026-04-27', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (681, 'NORMAL', NULL, '2026-04-28 11:14:41.082798', 127, '2026-04-27', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (682, 'NORMAL', NULL, '2026-04-28 11:14:41.084702', 92, '2026-04-27', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (683, 'NORMAL', NULL, '2026-04-28 11:14:41.085730', 166, '2026-04-27', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (684, 'NORMAL', NULL, '2026-04-28 11:14:41.086825', 148, '2026-04-27', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (685, 'NORMAL', NULL, '2026-04-28 11:14:41.089854', 116, '2026-04-27', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (686, 'NORMAL', NULL, '2026-04-28 11:14:41.092662', 119, '2026-04-27', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (687, 'NORMAL', NULL, '2026-04-29 13:42:06.189476', 0, '2026-04-28', 1, '红烧肉', 95, 4, 99);
INSERT INTO `daily_dish_statistics` VALUES (688, 'NORMAL', NULL, '2026-04-29 13:42:06.265989', 100, '2026-04-28', 2, '宫保鸡丁', 96, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (689, 'NORMAL', NULL, '2026-04-29 13:42:06.270043', 100, '2026-04-28', 3, '麻婆豆腐', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (690, 'NORMAL', NULL, '2026-04-29 13:42:06.273866', 100, '2026-04-28', 4, '西红柿鸡蛋', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (691, 'NORMAL', NULL, '2026-04-29 13:42:06.276236', 100, '2026-04-28', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (692, 'NORMAL', NULL, '2026-04-29 13:42:06.278971', 100, '2026-04-28', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (693, 'NORMAL', NULL, '2026-04-29 13:42:06.283908', 0, '2026-04-28', 7, '鱼香肉丝', 28, 1, 29);
INSERT INTO `daily_dish_statistics` VALUES (694, 'NORMAL', NULL, '2026-04-29 13:42:06.288162', 73, '2026-04-28', 8, '清蒸鱼', 72, 1, 73);
INSERT INTO `daily_dish_statistics` VALUES (695, 'NORMAL', NULL, '2026-04-29 13:42:06.292052', 0, '2026-04-28', 9, '清真牛肉饭', 108, 1, 109);
INSERT INTO `daily_dish_statistics` VALUES (696, 'NORMAL', NULL, '2026-04-29 13:42:06.293860', 0, '2026-04-28', 10, '包子', 183, 2, 185);
INSERT INTO `daily_dish_statistics` VALUES (697, 'NORMAL', NULL, '2026-04-29 13:42:06.295995', 149, '2026-04-28', 11, '油条', 147, 2, 149);
INSERT INTO `daily_dish_statistics` VALUES (698, 'NORMAL', NULL, '2026-04-29 13:42:06.299235', 163, '2026-04-28', 12, '回锅肉', 162, 1, 163);
INSERT INTO `daily_dish_statistics` VALUES (699, 'NORMAL', NULL, '2026-04-29 13:42:06.301490', 186, '2026-04-28', 13, '白切鸡', 185, 1, 186);
INSERT INTO `daily_dish_statistics` VALUES (700, 'NORMAL', NULL, '2026-04-29 13:42:06.304825', 188, '2026-04-28', 14, '广东菜心', 187, 1, 188);
INSERT INTO `daily_dish_statistics` VALUES (701, 'NORMAL', NULL, '2026-04-29 13:42:06.306990', 0, '2026-04-28', 16, '烧腊饭', 198, 1, 199);
INSERT INTO `daily_dish_statistics` VALUES (702, 'NORMAL', NULL, '2026-04-29 13:42:06.310041', 174, '2026-04-28', 17, '糖醋里脊', 173, 1, 174);
INSERT INTO `daily_dish_statistics` VALUES (703, 'NORMAL', NULL, '2026-04-29 13:42:06.312572', 0, '2026-04-28', 18, '葱爆羊肉', 59, 1, 60);
INSERT INTO `daily_dish_statistics` VALUES (704, 'NORMAL', NULL, '2026-04-29 13:42:06.314202', 63, '2026-04-28', 19, '油焖大虾', 62, 1, 63);
INSERT INTO `daily_dish_statistics` VALUES (705, 'NORMAL', NULL, '2026-04-29 13:42:06.314947', 108, '2026-04-28', 21, '清炒时蔬', 107, 1, 108);
INSERT INTO `daily_dish_statistics` VALUES (706, 'NORMAL', NULL, '2026-04-29 13:42:06.318247', 0, '2026-04-28', 22, '西红柿鸡蛋面', 160, 1, 161);
INSERT INTO `daily_dish_statistics` VALUES (707, 'NORMAL', NULL, '2026-04-29 13:42:06.320502', 65, '2026-04-28', 23, '小笼包', 61, 1, 65);
INSERT INTO `daily_dish_statistics` VALUES (708, 'NORMAL', NULL, '2026-04-29 13:42:06.322772', 0, '2026-04-28', 24, '松鼠桂鱼', 155, 1, 156);
INSERT INTO `daily_dish_statistics` VALUES (709, 'NORMAL', NULL, '2026-04-29 13:42:06.324881', 57, '2026-04-28', 25, '清炒虾仁', 56, 1, 57);
INSERT INTO `daily_dish_statistics` VALUES (710, 'NORMAL', NULL, '2026-04-29 13:42:06.325871', 0, '2026-04-28', 26, '扬州炒饭', 182, 1, 183);
INSERT INTO `daily_dish_statistics` VALUES (711, 'NORMAL', NULL, '2026-04-29 13:42:06.328909', 133, '2026-04-28', 27, '剁椒鱼头', 132, 1, 133);
INSERT INTO `daily_dish_statistics` VALUES (712, 'NORMAL', NULL, '2026-04-29 13:42:06.332102', 127, '2026-04-28', 28, '农家小炒肉', 126, 1, 127);
INSERT INTO `daily_dish_statistics` VALUES (713, 'NORMAL', NULL, '2026-04-29 13:42:06.334834', 92, '2026-04-28', 29, '永州血鸭', 90, 2, 92);
INSERT INTO `daily_dish_statistics` VALUES (714, 'NORMAL', NULL, '2026-04-29 13:42:06.336691', 166, '2026-04-28', 30, '西湖醋鱼', 164, 2, 166);
INSERT INTO `daily_dish_statistics` VALUES (715, 'NORMAL', NULL, '2026-04-29 13:42:06.339503', 148, '2026-04-28', 31, '龙井虾仁', 147, 1, 148);
INSERT INTO `daily_dish_statistics` VALUES (716, 'NORMAL', NULL, '2026-04-29 13:42:06.341031', 116, '2026-04-28', 32, '叫花鸡', 114, 2, 116);
INSERT INTO `daily_dish_statistics` VALUES (717, 'NORMAL', NULL, '2026-04-29 13:42:06.344879', 119, '2026-04-28', 34, '奶茶', 117, 2, 119);
INSERT INTO `daily_dish_statistics` VALUES (718, 'NORMAL', NULL, '2026-04-30 17:17:23.740621', 0, '2026-04-29', 1, '红烧肉', 95, 0, 95);
INSERT INTO `daily_dish_statistics` VALUES (719, 'NORMAL', NULL, '2026-04-30 17:17:23.773390', 100, '2026-04-29', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (720, 'NORMAL', NULL, '2026-04-30 17:17:23.776674', 100, '2026-04-29', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (721, 'NORMAL', NULL, '2026-04-30 17:17:23.778278', 100, '2026-04-29', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (722, 'NORMAL', NULL, '2026-04-30 17:17:23.781337', 100, '2026-04-29', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (723, 'NORMAL', NULL, '2026-04-30 17:17:23.784025', 100, '2026-04-29', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (724, 'NORMAL', NULL, '2026-04-30 17:17:23.786079', 0, '2026-04-29', 7, '鱼香肉丝', 28, 0, 28);
INSERT INTO `daily_dish_statistics` VALUES (725, 'NORMAL', NULL, '2026-04-30 17:17:23.788310', 73, '2026-04-29', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (726, 'NORMAL', NULL, '2026-04-30 17:17:23.790892', 0, '2026-04-29', 9, '清真牛肉饭', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (727, 'NORMAL', NULL, '2026-04-30 17:17:23.793418', 0, '2026-04-29', 10, '包子', 183, 0, 183);
INSERT INTO `daily_dish_statistics` VALUES (728, 'NORMAL', NULL, '2026-04-30 17:17:23.796452', 149, '2026-04-29', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (729, 'NORMAL', NULL, '2026-04-30 17:17:23.797908', 163, '2026-04-29', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (730, 'NORMAL', NULL, '2026-04-30 17:17:23.801008', 186, '2026-04-29', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (731, 'NORMAL', NULL, '2026-04-30 17:17:23.803545', 188, '2026-04-29', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (732, 'NORMAL', NULL, '2026-04-30 17:17:23.805677', 0, '2026-04-29', 16, '烧腊饭', 198, 0, 198);
INSERT INTO `daily_dish_statistics` VALUES (733, 'NORMAL', NULL, '2026-04-30 17:17:23.807843', 174, '2026-04-29', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (734, 'NORMAL', NULL, '2026-04-30 17:17:23.809362', 0, '2026-04-29', 18, '葱爆羊肉', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (735, 'NORMAL', NULL, '2026-04-30 17:17:23.811919', 63, '2026-04-29', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (736, 'NORMAL', NULL, '2026-04-30 17:17:23.813428', 108, '2026-04-29', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (737, 'NORMAL', NULL, '2026-04-30 17:17:23.819932', 0, '2026-04-29', 22, '西红柿鸡蛋面', 160, 0, 160);
INSERT INTO `daily_dish_statistics` VALUES (738, 'NORMAL', NULL, '2026-04-30 17:17:23.830081', 65, '2026-04-29', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (739, 'NORMAL', NULL, '2026-04-30 17:17:23.837073', 0, '2026-04-29', 24, '松鼠桂鱼', 155, 0, 155);
INSERT INTO `daily_dish_statistics` VALUES (740, 'NORMAL', NULL, '2026-04-30 17:17:23.840646', 57, '2026-04-29', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (741, 'NORMAL', NULL, '2026-04-30 17:17:23.850966', 0, '2026-04-29', 26, '扬州炒饭', 182, 0, 182);
INSERT INTO `daily_dish_statistics` VALUES (742, 'NORMAL', NULL, '2026-04-30 17:17:23.867169', 133, '2026-04-29', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (743, 'NORMAL', NULL, '2026-04-30 17:17:23.881249', 127, '2026-04-29', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (744, 'NORMAL', NULL, '2026-04-30 17:17:23.888911', 92, '2026-04-29', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (745, 'NORMAL', NULL, '2026-04-30 17:17:23.895605', 166, '2026-04-29', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (746, 'NORMAL', NULL, '2026-04-30 17:17:23.902222', 148, '2026-04-29', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (747, 'NORMAL', NULL, '2026-04-30 17:17:23.905824', 116, '2026-04-29', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (748, 'NORMAL', NULL, '2026-04-30 17:17:23.914724', 119, '2026-04-29', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (749, 'NORMAL', NULL, '2026-05-08 20:53:51.040439', 0, '2026-05-07', 1, '红烧肉', 95, 0, 95);
INSERT INTO `daily_dish_statistics` VALUES (750, 'NORMAL', NULL, '2026-05-08 20:53:51.085633', 100, '2026-05-07', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (751, 'NORMAL', NULL, '2026-05-08 20:53:51.088021', 100, '2026-05-07', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (752, 'NORMAL', NULL, '2026-05-08 20:53:51.090493', 100, '2026-05-07', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (753, 'NORMAL', NULL, '2026-05-08 20:53:51.090493', 100, '2026-05-07', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (754, 'NORMAL', NULL, '2026-05-08 20:53:51.093167', 100, '2026-05-07', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (755, 'NORMAL', NULL, '2026-05-08 20:53:51.104369', 0, '2026-05-07', 7, '鱼香肉丝', 28, 0, 28);
INSERT INTO `daily_dish_statistics` VALUES (756, 'NORMAL', NULL, '2026-05-08 20:53:51.111504', 73, '2026-05-07', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (757, 'NORMAL', NULL, '2026-05-08 20:53:51.112693', 0, '2026-05-07', 9, '清真牛肉饭', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (758, 'NORMAL', NULL, '2026-05-08 20:53:51.115571', 0, '2026-05-07', 10, '包子', 183, 0, 183);
INSERT INTO `daily_dish_statistics` VALUES (759, 'NORMAL', NULL, '2026-05-08 20:53:51.115571', 149, '2026-05-07', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (760, 'NORMAL', NULL, '2026-05-08 20:53:51.115571', 163, '2026-05-07', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (761, 'NORMAL', NULL, '2026-05-08 20:53:51.118224', 186, '2026-05-07', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (762, 'NORMAL', NULL, '2026-05-08 20:53:51.118224', 188, '2026-05-07', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (763, 'NORMAL', NULL, '2026-05-08 20:53:51.120357', 0, '2026-05-07', 16, '烧腊饭', 198, 0, 198);
INSERT INTO `daily_dish_statistics` VALUES (764, 'NORMAL', NULL, '2026-05-08 20:53:51.131948', 174, '2026-05-07', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (765, 'NORMAL', NULL, '2026-05-08 20:53:51.137710', 0, '2026-05-07', 18, '葱爆羊肉', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (766, 'NORMAL', NULL, '2026-05-08 20:53:51.152654', 63, '2026-05-07', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (767, 'NORMAL', NULL, '2026-05-08 20:53:51.154745', 108, '2026-05-07', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (768, 'NORMAL', NULL, '2026-05-08 20:53:51.157954', 0, '2026-05-07', 22, '西红柿鸡蛋面', 160, 0, 160);
INSERT INTO `daily_dish_statistics` VALUES (769, 'NORMAL', NULL, '2026-05-08 20:53:51.160258', 65, '2026-05-07', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (770, 'NORMAL', NULL, '2026-05-08 20:53:51.162979', 0, '2026-05-07', 24, '松鼠桂鱼', 155, 0, 155);
INSERT INTO `daily_dish_statistics` VALUES (771, 'NORMAL', NULL, '2026-05-08 20:53:51.168267', 57, '2026-05-07', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (772, 'NORMAL', NULL, '2026-05-08 20:53:51.171693', 0, '2026-05-07', 26, '扬州炒饭', 182, 0, 182);
INSERT INTO `daily_dish_statistics` VALUES (773, 'NORMAL', NULL, '2026-05-08 20:53:51.174209', 133, '2026-05-07', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (774, 'NORMAL', NULL, '2026-05-08 20:53:51.176980', 127, '2026-05-07', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (775, 'NORMAL', NULL, '2026-05-08 20:53:51.179726', 92, '2026-05-07', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (776, 'NORMAL', NULL, '2026-05-08 20:53:51.183088', 166, '2026-05-07', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (777, 'NORMAL', NULL, '2026-05-08 20:53:51.185316', 148, '2026-05-07', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (778, 'NORMAL', NULL, '2026-05-08 20:53:51.185316', 116, '2026-05-07', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (779, 'NORMAL', NULL, '2026-05-08 20:53:51.187713', 119, '2026-05-07', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (780, 'NORMAL', NULL, '2026-05-09 21:55:52.866913', 0, '2026-05-08', 1, '红烧肉', 95, 0, 95);
INSERT INTO `daily_dish_statistics` VALUES (781, 'NORMAL', NULL, '2026-05-09 21:55:52.902134', 100, '2026-05-08', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (782, 'NORMAL', NULL, '2026-05-09 21:55:52.903692', 100, '2026-05-08', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (783, 'NORMAL', NULL, '2026-05-09 21:55:52.908737', 100, '2026-05-08', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (784, 'NORMAL', NULL, '2026-05-09 21:55:52.910762', 100, '2026-05-08', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (785, 'NORMAL', NULL, '2026-05-09 21:55:52.913224', 100, '2026-05-08', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (786, 'NORMAL', NULL, '2026-05-09 21:55:52.914652', 0, '2026-05-08', 7, '鱼香肉丝', 28, 0, 28);
INSERT INTO `daily_dish_statistics` VALUES (787, 'NORMAL', NULL, '2026-05-09 21:55:52.918743', 73, '2026-05-08', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (788, 'NORMAL', NULL, '2026-05-09 21:55:52.922299', 0, '2026-05-08', 9, '清真牛肉饭', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (789, 'NORMAL', NULL, '2026-05-09 21:55:52.924945', 0, '2026-05-08', 10, '包子', 183, 0, 183);
INSERT INTO `daily_dish_statistics` VALUES (790, 'NORMAL', NULL, '2026-05-09 21:55:52.927728', 149, '2026-05-08', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (791, 'NORMAL', NULL, '2026-05-09 21:55:52.928840', 163, '2026-05-08', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (792, 'NORMAL', NULL, '2026-05-09 21:55:52.938990', 186, '2026-05-08', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (793, 'NORMAL', NULL, '2026-05-09 21:55:52.942528', 188, '2026-05-08', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (794, 'NORMAL', NULL, '2026-05-09 21:55:52.945087', 0, '2026-05-08', 16, '烧腊饭', 198, 0, 198);
INSERT INTO `daily_dish_statistics` VALUES (795, 'NORMAL', NULL, '2026-05-09 21:55:52.950280', 174, '2026-05-08', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (796, 'NORMAL', NULL, '2026-05-09 21:55:52.954150', 0, '2026-05-08', 18, '葱爆羊肉', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (797, 'NORMAL', NULL, '2026-05-09 21:55:52.955675', 63, '2026-05-08', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (798, 'NORMAL', NULL, '2026-05-09 21:55:52.958685', 108, '2026-05-08', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (799, 'NORMAL', NULL, '2026-05-09 21:55:52.962272', 0, '2026-05-08', 22, '西红柿鸡蛋面', 160, 0, 160);
INSERT INTO `daily_dish_statistics` VALUES (800, 'NORMAL', NULL, '2026-05-09 21:55:52.965319', 65, '2026-05-08', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (801, 'NORMAL', NULL, '2026-05-09 21:55:52.967681', 0, '2026-05-08', 24, '松鼠桂鱼', 155, 0, 155);
INSERT INTO `daily_dish_statistics` VALUES (802, 'NORMAL', NULL, '2026-05-09 21:55:52.970763', 57, '2026-05-08', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (803, 'NORMAL', NULL, '2026-05-09 21:55:52.972834', 0, '2026-05-08', 26, '扬州炒饭', 182, 0, 182);
INSERT INTO `daily_dish_statistics` VALUES (804, 'NORMAL', NULL, '2026-05-09 21:55:52.974889', 133, '2026-05-08', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (805, 'NORMAL', NULL, '2026-05-09 21:55:52.980370', 127, '2026-05-08', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (806, 'NORMAL', NULL, '2026-05-09 21:55:52.984208', 92, '2026-05-08', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (807, 'NORMAL', NULL, '2026-05-09 21:55:52.986670', 166, '2026-05-08', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (808, 'NORMAL', NULL, '2026-05-09 21:55:52.991963', 148, '2026-05-08', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (809, 'NORMAL', NULL, '2026-05-09 21:55:52.995101', 116, '2026-05-08', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (810, 'NORMAL', NULL, '2026-05-09 21:55:52.997504', 119, '2026-05-08', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (811, 'NORMAL', NULL, '2026-05-10 16:42:08.986929', 0, '2026-05-09', 1, '红烧肉', 95, 0, 95);
INSERT INTO `daily_dish_statistics` VALUES (812, 'NORMAL', NULL, '2026-05-10 16:42:09.006907', 100, '2026-05-09', 2, '宫保鸡丁', 100, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (813, 'NORMAL', NULL, '2026-05-10 16:42:09.008810', 100, '2026-05-09', 3, '麻婆豆腐', 100, 2, 100);
INSERT INTO `daily_dish_statistics` VALUES (814, 'NORMAL', NULL, '2026-05-10 16:42:09.008810', 100, '2026-05-09', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (815, 'NORMAL', NULL, '2026-05-10 16:42:09.011521', 100, '2026-05-09', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (816, 'NORMAL', NULL, '2026-05-10 16:42:09.017536', 100, '2026-05-09', 6, '紫菜蛋花汤', 100, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (817, 'NORMAL', NULL, '2026-05-10 16:42:09.017536', 0, '2026-05-09', 7, '鱼香肉丝', 28, 1, 29);
INSERT INTO `daily_dish_statistics` VALUES (818, 'NORMAL', NULL, '2026-05-10 16:42:09.019900', 73, '2026-05-09', 8, '清蒸鱼', 73, 2, 73);
INSERT INTO `daily_dish_statistics` VALUES (819, 'NORMAL', NULL, '2026-05-10 16:42:09.019900', 0, '2026-05-09', 9, '清真牛肉饭', 108, 1, 109);
INSERT INTO `daily_dish_statistics` VALUES (820, 'NORMAL', NULL, '2026-05-10 16:42:09.021598', 0, '2026-05-09', 10, '包子', 183, 4, 187);
INSERT INTO `daily_dish_statistics` VALUES (821, 'NORMAL', NULL, '2026-05-10 16:42:09.022609', 149, '2026-05-09', 11, '油条', 149, 1, 149);
INSERT INTO `daily_dish_statistics` VALUES (822, 'NORMAL', NULL, '2026-05-10 16:42:09.022609', 163, '2026-05-09', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (823, 'NORMAL', NULL, '2026-05-10 16:42:09.022609', 186, '2026-05-09', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (824, 'NORMAL', NULL, '2026-05-10 16:42:09.022609', 188, '2026-05-09', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (825, 'NORMAL', NULL, '2026-05-10 16:42:09.027857', 0, '2026-05-09', 16, '烧腊饭', 198, 0, 198);
INSERT INTO `daily_dish_statistics` VALUES (826, 'NORMAL', NULL, '2026-05-10 16:42:09.028386', 174, '2026-05-09', 17, '糖醋里脊', 174, 1, 174);
INSERT INTO `daily_dish_statistics` VALUES (827, 'NORMAL', NULL, '2026-05-10 16:42:09.031995', 0, '2026-05-09', 18, '葱爆羊肉', 59, 1, 60);
INSERT INTO `daily_dish_statistics` VALUES (828, 'NORMAL', NULL, '2026-05-10 16:42:09.037099', 63, '2026-05-09', 19, '油焖大虾', 63, 1, 63);
INSERT INTO `daily_dish_statistics` VALUES (829, 'NORMAL', NULL, '2026-05-10 16:42:09.041174', 108, '2026-05-09', 21, '清炒时蔬', 108, 2, 108);
INSERT INTO `daily_dish_statistics` VALUES (830, 'NORMAL', NULL, '2026-05-10 16:42:09.042973', 0, '2026-05-09', 22, '西红柿鸡蛋面', 160, 3, 163);
INSERT INTO `daily_dish_statistics` VALUES (831, 'NORMAL', NULL, '2026-05-10 16:42:09.044956', 65, '2026-05-09', 23, '小笼包', 65, 1, 65);
INSERT INTO `daily_dish_statistics` VALUES (832, 'NORMAL', NULL, '2026-05-10 16:42:09.047770', 0, '2026-05-09', 24, '松鼠桂鱼', 155, 1, 156);
INSERT INTO `daily_dish_statistics` VALUES (833, 'NORMAL', NULL, '2026-05-10 16:42:09.047770', 57, '2026-05-09', 25, '清炒虾仁', 57, 1, 57);
INSERT INTO `daily_dish_statistics` VALUES (834, 'NORMAL', NULL, '2026-05-10 16:42:09.051606', 0, '2026-05-09', 26, '扬州炒饭', 182, 0, 182);
INSERT INTO `daily_dish_statistics` VALUES (835, 'NORMAL', NULL, '2026-05-10 16:42:09.053274', 133, '2026-05-09', 27, '剁椒鱼头', 133, 3, 133);
INSERT INTO `daily_dish_statistics` VALUES (836, 'NORMAL', NULL, '2026-05-10 16:42:09.053775', 127, '2026-05-09', 28, '农家小炒肉', 127, 1, 127);
INSERT INTO `daily_dish_statistics` VALUES (837, 'NORMAL', NULL, '2026-05-10 16:42:09.059239', 92, '2026-05-09', 29, '永州血鸭', 92, 1, 92);
INSERT INTO `daily_dish_statistics` VALUES (838, 'NORMAL', NULL, '2026-05-10 16:42:09.061246', 166, '2026-05-09', 30, '西湖醋鱼', 166, 2, 166);
INSERT INTO `daily_dish_statistics` VALUES (839, 'NORMAL', NULL, '2026-05-10 16:42:09.061728', 148, '2026-05-09', 31, '龙井虾仁', 147, 2, 148);
INSERT INTO `daily_dish_statistics` VALUES (840, 'NORMAL', NULL, '2026-05-10 16:42:09.066317', 116, '2026-05-09', 32, '叫花鸡', 115, 1, 116);
INSERT INTO `daily_dish_statistics` VALUES (841, 'NORMAL', NULL, '2026-05-10 16:42:09.067161', 119, '2026-05-09', 34, '奶茶', 119, 1, 119);
INSERT INTO `daily_dish_statistics` VALUES (842, 'NORMAL', NULL, '2026-05-11 13:16:30.693777', 0, '2026-05-10', 1, '红烧肉', 95, 0, 95);
INSERT INTO `daily_dish_statistics` VALUES (843, 'NORMAL', NULL, '2026-05-11 13:16:30.712425', 100, '2026-05-10', 2, '宫保鸡丁', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (844, 'NORMAL', NULL, '2026-05-11 13:16:30.715659', 100, '2026-05-10', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (845, 'NORMAL', NULL, '2026-05-11 13:16:30.717250', 100, '2026-05-10', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (846, 'NORMAL', NULL, '2026-05-11 13:16:30.718453', 100, '2026-05-10', 5, '青椒土豆丝', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (847, 'NORMAL', NULL, '2026-05-11 13:16:30.724611', 100, '2026-05-10', 6, '紫菜蛋花汤', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (848, 'NORMAL', NULL, '2026-05-11 13:16:30.724611', 0, '2026-05-10', 7, '鱼香肉丝', 28, 0, 28);
INSERT INTO `daily_dish_statistics` VALUES (849, 'NORMAL', NULL, '2026-05-11 13:16:30.724611', 73, '2026-05-10', 8, '清蒸鱼', 73, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (850, 'NORMAL', NULL, '2026-05-11 13:16:30.726617', 0, '2026-05-10', 9, '清真牛肉饭', 108, 2, 110);
INSERT INTO `daily_dish_statistics` VALUES (851, 'NORMAL', NULL, '2026-05-11 13:16:30.733360', 0, '2026-05-10', 10, '包子', 183, 0, 183);
INSERT INTO `daily_dish_statistics` VALUES (852, 'NORMAL', NULL, '2026-05-11 13:16:30.737729', 149, '2026-05-10', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (853, 'NORMAL', NULL, '2026-05-11 13:16:30.743441', 163, '2026-05-10', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (854, 'NORMAL', NULL, '2026-05-11 13:16:30.753070', 186, '2026-05-10', 13, '白切鸡', 186, 0, 186);
INSERT INTO `daily_dish_statistics` VALUES (855, 'NORMAL', NULL, '2026-05-11 13:16:30.754549', 188, '2026-05-10', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (856, 'NORMAL', NULL, '2026-05-11 13:16:30.757350', 0, '2026-05-10', 16, '烧腊饭', 198, 0, 198);
INSERT INTO `daily_dish_statistics` VALUES (857, 'NORMAL', NULL, '2026-05-11 13:16:30.760209', 174, '2026-05-10', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (858, 'NORMAL', NULL, '2026-05-11 13:16:30.768470', 0, '2026-05-10', 18, '葱爆羊肉', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (859, 'NORMAL', NULL, '2026-05-11 13:16:30.768898', 63, '2026-05-10', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (860, 'NORMAL', NULL, '2026-05-11 13:16:30.773408', 108, '2026-05-10', 21, '清炒时蔬', 108, 0, 108);
INSERT INTO `daily_dish_statistics` VALUES (861, 'NORMAL', NULL, '2026-05-11 13:16:30.776785', 0, '2026-05-10', 22, '西红柿鸡蛋面', 160, 0, 160);
INSERT INTO `daily_dish_statistics` VALUES (862, 'NORMAL', NULL, '2026-05-11 13:16:30.779979', 65, '2026-05-10', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (863, 'NORMAL', NULL, '2026-05-11 13:16:30.779979', 0, '2026-05-10', 24, '松鼠桂鱼', 155, 0, 155);
INSERT INTO `daily_dish_statistics` VALUES (864, 'NORMAL', NULL, '2026-05-11 13:16:30.783447', 57, '2026-05-10', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (865, 'NORMAL', NULL, '2026-05-11 13:16:30.785451', 0, '2026-05-10', 26, '扬州炒饭', 182, 0, 182);
INSERT INTO `daily_dish_statistics` VALUES (866, 'NORMAL', NULL, '2026-05-11 13:16:30.786455', 133, '2026-05-10', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (867, 'NORMAL', NULL, '2026-05-11 13:16:30.787920', 127, '2026-05-10', 28, '农家小炒肉', 127, 0, 127);
INSERT INTO `daily_dish_statistics` VALUES (868, 'NORMAL', NULL, '2026-05-11 13:16:30.790661', 92, '2026-05-10', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (869, 'NORMAL', NULL, '2026-05-11 13:16:30.793670', 166, '2026-05-10', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (870, 'NORMAL', NULL, '2026-05-11 13:16:30.796327', 148, '2026-05-10', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (871, 'NORMAL', NULL, '2026-05-11 13:16:30.798025', 0, '2026-05-10', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (872, 'NORMAL', NULL, '2026-05-11 13:16:30.799028', 119, '2026-05-10', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (873, 'NORMAL', NULL, '2026-05-12 08:48:42.126328', 0, '2026-05-11', 1, '红烧肉', 94, 1, 95);
INSERT INTO `daily_dish_statistics` VALUES (874, 'NORMAL', NULL, '2026-05-12 08:48:42.126328', 100, '2026-05-11', 2, '宫保鸡丁', 99, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (875, 'NORMAL', NULL, '2026-05-12 08:48:42.127816', 100, '2026-05-11', 3, '麻婆豆腐', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (876, 'NORMAL', NULL, '2026-05-12 08:48:42.127816', 100, '2026-05-11', 4, '西红柿鸡蛋', 100, 0, 100);
INSERT INTO `daily_dish_statistics` VALUES (877, 'NORMAL', NULL, '2026-05-12 08:48:42.127816', 100, '2026-05-11', 5, '青椒土豆丝', 99, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (878, 'NORMAL', NULL, '2026-05-12 08:48:42.127816', 100, '2026-05-11', 6, '紫菜蛋花汤', 98, 1, 100);
INSERT INTO `daily_dish_statistics` VALUES (879, 'NORMAL', NULL, '2026-05-12 08:48:42.130575', 0, '2026-05-11', 7, '鱼香肉丝', 27, 0, 27);
INSERT INTO `daily_dish_statistics` VALUES (880, 'NORMAL', NULL, '2026-05-12 08:48:42.130575', 73, '2026-05-11', 8, '清蒸鱼', 72, 0, 73);
INSERT INTO `daily_dish_statistics` VALUES (881, 'NORMAL', NULL, '2026-05-12 08:48:42.136124', 0, '2026-05-11', 9, '清真牛肉饭', 107, 1, 108);
INSERT INTO `daily_dish_statistics` VALUES (882, 'NORMAL', NULL, '2026-05-12 08:48:42.137438', 0, '2026-05-11', 10, '包子', 183, 0, 183);
INSERT INTO `daily_dish_statistics` VALUES (883, 'NORMAL', NULL, '2026-05-12 08:48:42.138916', 149, '2026-05-11', 11, '油条', 149, 0, 149);
INSERT INTO `daily_dish_statistics` VALUES (884, 'NORMAL', NULL, '2026-05-12 08:48:42.138916', 163, '2026-05-11', 12, '回锅肉', 163, 0, 163);
INSERT INTO `daily_dish_statistics` VALUES (885, 'NORMAL', NULL, '2026-05-12 08:48:42.141650', 186, '2026-05-11', 13, '白切鸡', 186, 1, 186);
INSERT INTO `daily_dish_statistics` VALUES (886, 'NORMAL', NULL, '2026-05-12 08:48:42.145950', 188, '2026-05-11', 14, '广东菜心', 188, 0, 188);
INSERT INTO `daily_dish_statistics` VALUES (887, 'NORMAL', NULL, '2026-05-12 08:48:42.150024', 0, '2026-05-11', 16, '烧腊饭', 198, 1, 199);
INSERT INTO `daily_dish_statistics` VALUES (888, 'NORMAL', NULL, '2026-05-12 08:48:42.152747', 174, '2026-05-11', 17, '糖醋里脊', 174, 0, 174);
INSERT INTO `daily_dish_statistics` VALUES (889, 'NORMAL', NULL, '2026-05-12 08:48:42.156262', 0, '2026-05-11', 18, '葱爆羊肉', 59, 0, 59);
INSERT INTO `daily_dish_statistics` VALUES (890, 'NORMAL', NULL, '2026-05-12 08:48:42.158353', 63, '2026-05-11', 19, '油焖大虾', 63, 0, 63);
INSERT INTO `daily_dish_statistics` VALUES (891, 'NORMAL', NULL, '2026-05-12 08:48:42.176962', 108, '2026-05-11', 21, '清炒时蔬', 107, 1, 108);
INSERT INTO `daily_dish_statistics` VALUES (892, 'NORMAL', NULL, '2026-05-12 08:48:42.179057', 0, '2026-05-11', 22, '西红柿鸡蛋面', 159, 1, 160);
INSERT INTO `daily_dish_statistics` VALUES (893, 'NORMAL', NULL, '2026-05-12 08:48:42.185040', 65, '2026-05-11', 23, '小笼包', 65, 0, 65);
INSERT INTO `daily_dish_statistics` VALUES (894, 'NORMAL', NULL, '2026-05-12 08:48:42.188903', 0, '2026-05-11', 24, '松鼠桂鱼', 155, 0, 155);
INSERT INTO `daily_dish_statistics` VALUES (895, 'NORMAL', NULL, '2026-05-12 08:48:42.191723', 57, '2026-05-11', 25, '清炒虾仁', 57, 0, 57);
INSERT INTO `daily_dish_statistics` VALUES (896, 'NORMAL', NULL, '2026-05-12 08:48:42.191723', 0, '2026-05-11', 26, '扬州炒饭', 182, 0, 182);
INSERT INTO `daily_dish_statistics` VALUES (897, 'NORMAL', NULL, '2026-05-12 08:48:42.194505', 133, '2026-05-11', 27, '剁椒鱼头', 133, 0, 133);
INSERT INTO `daily_dish_statistics` VALUES (898, 'NORMAL', NULL, '2026-05-12 08:48:42.197243', 127, '2026-05-11', 28, '农家小炒肉', 127, 1, 127);
INSERT INTO `daily_dish_statistics` VALUES (899, 'NORMAL', NULL, '2026-05-12 08:48:42.197243', 92, '2026-05-11', 29, '永州血鸭', 92, 0, 92);
INSERT INTO `daily_dish_statistics` VALUES (900, 'NORMAL', NULL, '2026-05-12 08:48:42.200077', 166, '2026-05-11', 30, '西湖醋鱼', 166, 0, 166);
INSERT INTO `daily_dish_statistics` VALUES (901, 'NORMAL', NULL, '2026-05-12 08:48:42.201298', 148, '2026-05-11', 31, '龙井虾仁', 148, 0, 148);
INSERT INTO `daily_dish_statistics` VALUES (902, 'NORMAL', NULL, '2026-05-12 08:48:42.202821', 0, '2026-05-11', 32, '叫花鸡', 116, 0, 116);
INSERT INTO `daily_dish_statistics` VALUES (903, 'NORMAL', NULL, '2026-05-12 08:48:42.204529', 119, '2026-05-11', 34, '奶茶', 119, 0, 119);
INSERT INTO `daily_dish_statistics` VALUES (904, 'NORMAL', NULL, '2026-05-12 08:48:42.206899', 0, '2026-05-11', 59, '广式肠粉', 50, 0, 50);

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
INSERT INTO `dish_taste_tags` VALUES (8, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (8, '辣', NULL);
INSERT INTO `dish_taste_tags` VALUES (12, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (12, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (13, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (17, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (17, '甜', NULL);
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
INSERT INTO `dish_taste_tags` VALUES (30, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (30, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (31, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (34, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (26, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (26, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (24, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (24, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (18, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (7, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (7, '酸', NULL);
INSERT INTO `dish_taste_tags` VALUES (1, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (1, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (10, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (10, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (10, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (9, '重口味', NULL);
INSERT INTO `dish_taste_tags` VALUES (9, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (16, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (16, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (22, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (22, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (32, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (59, '甜', NULL);
INSERT INTO `dish_taste_tags` VALUES (59, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (59, '清淡', NULL);
INSERT INTO `dish_taste_tags` VALUES (29, '咸', NULL);
INSERT INTO `dish_taste_tags` VALUES (29, '重口', NULL);
INSERT INTO `dish_taste_tags` VALUES (14, '清淡', NULL);

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
  `sub_category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `category_id` bigint NULL DEFAULT NULL,
  `sales_count` int NULL DEFAULT 0 COMMENT '总销量',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_window_id`(`window_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_is_promotion`(`is_promotion` ASC) USING BTREE,
  INDEX `FKgbu6erefir17660qutbbjnma7`(`category_id` ASC) USING BTREE,
  CONSTRAINT `FKgbu6erefir17660qutbbjnma7` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of dishes
-- ----------------------------
INSERT INTO `dishes` VALUES (1, '红烧肉', '肥瘦相间，酱香浓郁，入口软糯不腻，经典下饭菜。', 12.00, '/uploads/7b08616e-4e8f-4416-b977-1594c25a13b3.jpg', 1, 350, 15.20, 20.50, 12.30, 'AVAILABLE', 94, 0, 1, 9.60, '2026-05-10 00:00:00', '2027-05-21 00:00:00', 5, 2, '2025-12-24 15:11:32', '2026-05-12 11:36:37', 1, '第一食堂', '一楼东侧', '上海菜窗口', 'MEAT_DISH', NULL, 'discount', NULL, NULL, 69);
INSERT INTO `dishes` VALUES (2, '宫保鸡丁', '鸡丁鲜嫩，花生香脆，酸甜微辣，口感层次丰富。', 10.00, '/uploads/5406bcfd-634e-461b-8961-fb28e4db4150.jpg', 12, 280, 18.50, 12.20, 15.60, 'AVAILABLE', 100, 100, 1, 7.00, '2026-05-10 00:00:00', '2027-05-28 00:00:00', 4.4, 5, '2025-12-24 15:11:32', '2026-05-12 08:54:40', 2, '第二食堂', '一楼西侧', '川菜窗口', 'MEAT_DISH', NULL, 'special', NULL, NULL, 50);
INSERT INTO `dishes` VALUES (3, '麻婆豆腐', '麻辣鲜香，豆腐嫩滑入味，搭配米饭更过瘾。', 8.00, '/uploads/b410b22a-a5e5-4ef3-bacd-f444fd00ebd3.jpg', 20, 180, 8.20, 10.10, 12.50, 'AVAILABLE', 100, 100, 0, 4.00, '2026-03-27 00:00:00', '2026-03-31 00:00:00', 5, 1, '2025-12-24 15:11:32', '2026-04-28 12:10:24', 3, '第三食堂', '一楼南侧', '川菜窗口', 'VEGETABLE', NULL, 'special', NULL, NULL, 4);
INSERT INTO `dishes` VALUES (4, '西红柿鸡蛋', '家常经典，酸甜开胃，鸡蛋滑嫩，清爽不油腻。', 7.00, '/uploads/b97ef2fd-6801-416c-a344-101deaeac257.png', 6, 150, 9.10, 8.30, 10.20, 'AVAILABLE', 100, 100, 0, 6.65, '2026-02-11 00:00:00', '2026-02-28 00:00:00', 5, 1, '2025-12-24 15:11:32', '2026-04-28 11:18:33', 1, '第一食堂', '二楼东侧', '特色菜窗口', 'VEGETABLE', NULL, 'discount', NULL, NULL, 1);
INSERT INTO `dishes` VALUES (5, '青椒土豆丝', '脆爽清香，咸鲜适口，简单家常却很下饭。', 5.00, '/uploads/f821ed7a-8e24-4751-a02e-efecaf3d2814.jpg', 15, 80, 2.10, 0.50, 18.20, 'AVAILABLE', 100, 100, 0, 4.75, '2026-02-11 00:00:00', '2026-02-28 00:00:00', 0, 0, '2025-12-24 15:11:32', '2026-05-11 13:20:42', 2, '第二食堂', '二楼西侧', '特色菜窗口', 'VEGETABLE', NULL, 'discount', NULL, NULL, 2);
INSERT INTO `dishes` VALUES (6, '紫菜蛋花汤', '清淡鲜美，汤汁顺口，暖胃舒适，搭配主食更合适。', 3.00, '/uploads/88a71dfc-fbc2-467a-8390-09422c8d0d87.jpg', 21, 50, 3.20, 1.80, 2.50, 'AVAILABLE', 99, 100, 0, NULL, NULL, NULL, 2, 1, '2025-12-24 15:11:32', '2026-05-12 08:48:50', 3, '第三食堂', '二楼南侧', '汤品窗口', 'SOUP', NULL, NULL, NULL, NULL, 3);
INSERT INTO `dishes` VALUES (7, '鱼香肉丝', '酸甜微辣，肉丝爽滑，酱香浓郁，开胃下饭。', 10.00, '/uploads/98147ca8-bd76-4d6c-8324-6f160dc314d3.png', 2, 104, 13.40, 5.30, 22.20, 'AVAILABLE', 26, 0, 0, 10.00, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-05-12 08:48:50', 1, '第一食堂', '三楼东侧', '川菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 3);
INSERT INTO `dishes` VALUES (8, '清蒸鱼', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 20.00, '/uploads/356ae620-4d79-405e-a8f2-446be5ad0005.jpg', 15, 252, 13.40, 7.90, 24.70, 'AVAILABLE', 73, 73, 0, 15.00, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-05-11 13:20:47', 2, '第二食堂', '三楼西侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 71);
INSERT INTO `dishes` VALUES (9, '清真牛肉饭', '精选牛肉，搭配米饭', 16.00, '/uploads/f12f549d-0103-41cb-8583-a11534e680a0.jpg', 23, 153, 5.60, 14.00, 36.80, 'AVAILABLE', 107, 0, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-11 13:20:42', 3, '第三食堂', '三楼南侧', '清真窗口', 'MAIN_DISH', NULL, NULL, NULL, NULL, 2);
INSERT INTO `dishes` VALUES (10, '包子', '传统面食，多种馅料', 2.00, '/uploads/b5364337-aec2-4ff3-8b83-aee27b3991db.jpg', 3, 364, 16.00, 12.40, 48.60, 'AVAILABLE', 182, 0, 0, 2.00, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-12 08:49:11', 1, '第一食堂', '一楼西侧', '早餐窗口', 'SNACK', NULL, '', NULL, NULL, 2);
INSERT INTO `dishes` VALUES (11, '油条', '早餐必备，酥脆可口', 1.50, '/uploads/c37da0e0-ff7a-4edc-9196-5e9773f64f6b.png', 13, 251, 11.30, 3.60, 18.70, 'AVAILABLE', 148, 149, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-12 08:48:51', 2, '第二食堂', '一楼西侧', '早餐窗口', 'SNACK', NULL, NULL, NULL, NULL, 2);
INSERT INTO `dishes` VALUES (12, '回锅肉', '肥而不腻，蒜苗提香，香辣过瘾，经典川味。', 28.00, '/uploads/4c94eb2c-e708-4604-a41b-facfdcf87276.jpg', 2, 150, 10.30, 16.00, 22.10, 'AVAILABLE', 163, 163, 0, NULL, NULL, NULL, 4, 1, '2025-12-24 15:11:32', '2026-04-28 12:07:49', 1, '第一食堂', '二楼东侧', '川菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (13, '白切鸡', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 38.00, '/uploads/b865e44a-e1b2-44fc-8444-55056406b0c6.jpg', 17, 178, 10.30, 17.10, 42.00, 'AVAILABLE', 186, 186, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-04-28 12:07:30', 2, '第二食堂', '二楼西侧', '粤菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (14, '广东菜心', '清爽不腻，口感自然，家常做法，健康又好吃。', 16.00, '/uploads/ef5ba583-6157-4891-8cb6-862a66530200.jpg', 26, 339, 10.10, 10.70, 39.20, 'AVAILABLE', 50, 0, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-05-12 08:51:22', 3, '第三食堂', '二楼南侧', '粤菜窗口', 'VEGETABLE', NULL, NULL, NULL, NULL, 3);
INSERT INTO `dishes` VALUES (16, '烧腊饭', '经典粤菜，香气四溢', 32.00, '/uploads/dcbeb7ef-7ea8-440b-b541-23b43e172a29.jpg', 8, 140, 18.20, 11.40, 32.20, 'AVAILABLE', 197, 0, 0, NULL, NULL, NULL, 3.5, 2, '2025-12-24 15:11:32', '2026-05-12 09:06:32', 1, '第一食堂', '三楼东侧', '粤菜窗口', 'MAIN_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (17, '糖醋里脊', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 35.00, '/uploads/1552a1e6-3304-4b82-8c3f-541feeb2b182.png', 15, 117, 8.60, 17.80, 41.10, 'AVAILABLE', 174, 174, 0, NULL, NULL, NULL, 4, 1, '2025-12-24 15:11:32', '2026-04-28 12:07:30', 2, '第二食堂', '三楼西侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (18, '葱爆羊肉', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 42.00, '/uploads/71c4e6e8-5bd7-4a94-9ebd-0fdfba641077.jpg', 25, 331, 16.50, 10.70, 34.60, 'AVAILABLE', 59, 0, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-04-28 12:10:24', 3, '第三食堂', '三楼南侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 70);
INSERT INTO `dishes` VALUES (19, '油焖大虾', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 48.00, '/uploads/3a3b9cec-f73f-4f4f-9615-a1d3a90edfe2.jpg', 10, 110, 11.80, 8.50, 35.80, 'AVAILABLE', 63, 63, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-04-28 12:03:07', 1, '第一食堂', '一楼东侧', '鲁菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (21, '清炒时蔬', '清爽不腻，口感自然，家常做法，健康又好吃。', 15.00, '/uploads/e331c11a-2f62-4eb9-8c03-075883055426.jpg', 25, 186, 13.00, 2.30, 14.10, 'AVAILABLE', 105, 108, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-12 11:38:05', 3, '第三食堂', '一楼南侧', '特色菜窗口', 'VEGETABLE', NULL, NULL, NULL, NULL, 3);
INSERT INTO `dishes` VALUES (22, '西红柿鸡蛋面', '经典面食，酸甜可口', 12.00, '/uploads/4e9d3ecf-c911-4567-a96f-bc5dc04852ef.jpg', 9, 137, 6.40, 5.90, 49.50, 'AVAILABLE', 158, 0, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-12 11:38:05', 1, '第一食堂', '二楼东侧', '面食窗口', 'MAIN_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (23, '小笼包', '外酥里嫩，香气十足，适合作为加餐或解馋小吃。', 10.00, '/uploads/4ad40111-de98-441f-9bc6-8ad6f21f0af2.jpg', 11, 202, 13.80, 7.40, 49.50, 'AVAILABLE', 62, 65, 0, NULL, NULL, NULL, 3.5, 2, '2025-12-24 15:11:32', '2026-05-12 09:06:32', 2, '第二食堂', '二楼西侧', '上海菜窗口', 'SNACK', NULL, NULL, NULL, NULL, 54);
INSERT INTO `dishes` VALUES (24, '松鼠桂鱼', '造型美观，外酥里嫩', 68.00, '/uploads/cebcdf1e-f91d-424e-9b88-4a0e9f792f03.jpg', 27, 367, 8.20, 19.10, 39.90, 'AVAILABLE', 155, 0, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-04-28 12:13:42', 3, '第三食堂', '二楼南侧', '苏菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 4);
INSERT INTO `dishes` VALUES (25, '清炒虾仁', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 58.00, '/uploads/f9fd92ab-9a74-41bb-935e-6382006713c0.jpg', 6, 210, 10.30, 13.60, 46.70, 'AVAILABLE', 56, 57, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-05-12 11:38:05', 1, '第一食堂', '三楼东侧', '特色菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 54);
INSERT INTO `dishes` VALUES (26, '扬州炒饭', '颗粒分明，营养丰富', 22.00, '/uploads/fc46df66-155c-4dd0-a4fe-d153a9187219.jpg', 16, 168, 8.40, 9.10, 32.30, 'AVAILABLE', 182, 0, 0, NULL, NULL, NULL, 4, 1, '2025-12-24 15:11:32', '2026-04-28 12:06:18', 2, '第二食堂', '三楼西侧', '盖浇饭窗口', 'MAIN_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (27, '剁椒鱼头', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 58.00, '/uploads/6a966b06-0025-472a-91ac-ae63fa97097d.jpg', 24, 330, 11.90, 15.90, 14.10, 'AVAILABLE', 133, 133, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-04-28 12:12:10', 3, '第三食堂', '三楼南侧', '湘菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 4);
INSERT INTO `dishes` VALUES (28, '农家小炒肉', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 32.00, '/uploads/0d05a268-45e9-4891-9d8a-5fcb840894b8.png', 5, 222, 6.10, 16.20, 11.40, 'AVAILABLE', 127, 127, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-04-28 12:10:24', 1, '第一食堂', '一楼东侧', '湘菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 2);
INSERT INTO `dishes` VALUES (29, '永州血鸭', '肉香浓郁，咸鲜入味，口感丰富，特别下饭。', 45.00, '/uploads/30144d1a-1e1e-4ee5-b69e-a29b306569f6.jpg', 14, 317, 5.30, 19.00, 22.20, 'AVAILABLE', 4, 0, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-05-12 08:50:27', 2, '第二食堂', '一楼西侧', '湘菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 2);
INSERT INTO `dishes` VALUES (30, '西湖醋鱼', '酸甜可口，鱼香四溢', 48.00, '/uploads/dbec63d4-ff3d-430e-ac3b-e71e87c468b8.jpg', 22, 183, 6.80, 13.00, 41.50, 'AVAILABLE', 166, 166, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-11 13:17:20', 3, '第三食堂', '一楼南侧', '浙菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 2);
INSERT INTO `dishes` VALUES (31, '龙井虾仁', '茶香四溢，虾仁鲜甜可口', 68.00, '/uploads/b9cb4f4d-dfdc-4099-b805-283aa0e1d77d.jpg', 4, 204, 14.00, 12.10, 42.10, 'AVAILABLE', 147, 148, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-12 08:49:07', 1, '第一食堂', '二楼东侧', '浙菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (32, '叫花鸡', '肉香浓郁，咸鲜入味，口感丰富', 52.00, '/uploads/c8d3de73-ddff-4cc1-a840-a2eb74147d9d.jpg', 18, 201, 16.80, 14.30, 15.50, 'AVAILABLE', 116, 0, 0, NULL, NULL, NULL, 5, 2, '2025-12-24 15:11:32', '2026-05-10 16:44:30', 2, '第二食堂', '二楼西侧', '苏菜窗口', 'MEAT_DISH', NULL, NULL, NULL, NULL, 2);
INSERT INTO `dishes` VALUES (34, '奶茶', '清爽解渴，口感舒适，搭配餐食更畅快。', 18.00, '/uploads/7485f557-54c1-40be-8667-a25016e0aa5e.jpg', 7, 243, 6.10, 10.60, 41.90, 'AVAILABLE', 119, 119, 0, NULL, NULL, NULL, 5, 1, '2025-12-24 15:11:32', '2026-04-28 20:54:20', 1, '第一食堂', '三楼东侧', '甜品窗口', 'BEVERAGE', NULL, NULL, NULL, NULL, 1);
INSERT INTO `dishes` VALUES (59, '广式肠粉', '传统石磨，经典美味', 6.00, '/uploads/df80fb13-3879-4589-8605-4e05c52c4981.jpg', 8, 24, 12.00, 56.00, 80.00, 'AVAILABLE', 50, 0, 0, NULL, NULL, NULL, 0, 0, '2026-05-12 08:46:35', '2026-05-12 08:46:35', 1, '第一食堂', '三楼东侧', '粤菜窗口', 'MAIN_DISH', NULL, NULL, NULL, NULL, 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1534 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (1195, 164, 'ORDER', '订单【ORD1777348612244】支付成功，已为您安排制作。', '2026-04-28 11:56:53.640880', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1196, 164, 'ORDER', '您的订单【ORD1777348612244】商家已接单，正在为您制作中。', '2026-04-28 11:56:58.180650', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1197, 164, 'ORDER', '您的订单【ORD1777348612244】已制作完成，请前往取餐口取餐。', '2026-04-28 11:56:59.141991', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1198, 164, 'ORDER', '您的订单【ORD1777348612244】已完成，感谢您的光临！', '2026-04-28 11:57:00.198636', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1199, 50, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 11:57:40.157972', b'1', b'1', '2026-04-29 13:44:59.139074', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1200, 165, 'ORDER', '订单【ORD1777348690203】支付成功，已为您安排制作。', '2026-04-28 11:58:13.422431', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1201, 165, 'ORDER', '您的订单【ORD1777348690203】商家已接单，正在为您制作中。', '2026-04-28 11:58:19.816734', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1202, 165, 'ORDER', '您的订单【ORD1777348690203】已制作完成，请前往取餐口取餐。', '2026-04-28 11:58:21.007059', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1203, 165, 'ORDER', '您的订单【ORD1777348690203】已完成，感谢您的光临！', '2026-04-28 11:58:22.275090', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1204, 51, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 11:58:28.861783', b'1', b'1', '2026-04-29 13:44:59.139074', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1205, 168, 'ORDER', '订单【ORD1777348764707】支付成功，已为您安排制作。', '2026-04-28 11:59:27.274378', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1206, 168, 'ORDER', '您的订单【ORD1777348764707】商家已接单，正在为您制作中。', '2026-04-28 11:59:45.066810', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1207, 167, 'ORDER', '订单【ORD1777348742411】支付成功，已为您安排制作。', '2026-04-28 11:59:58.929494', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1208, 166, 'ORDER', '订单【ORD1777348734179】支付成功，已为您安排制作。', '2026-04-28 12:00:00.650611', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1209, 168, 'ORDER', '您的预约订单【ORD1777348764707】已制作完成，预约取餐时间 12:00，请准时到达取餐口。', '2026-04-28 12:00:17.520450', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1210, 166, 'ORDER', '您的订单【ORD1777348734179】商家已接单，正在为您制作中。', '2026-04-28 12:00:19.499008', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1211, 167, 'ORDER', '您的订单【ORD1777348742411】商家已接单，正在为您制作中。', '2026-04-28 12:00:20.775007', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1212, 166, 'ORDER', '您的订单【ORD1777348734179】已制作完成，请前往取餐口取餐。', '2026-04-28 12:00:21.894631', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1213, 166, 'ORDER', '您的订单【ORD1777348734179】已完成，感谢您的光临！', '2026-04-28 12:00:23.490142', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1214, 167, 'ORDER', '您的订单【ORD1777348742411】已制作完成，请前往取餐口取餐。', '2026-04-28 12:00:24.927308', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1215, 167, 'ORDER', '您的订单【ORD1777348742411】已完成，感谢您的光临！', '2026-04-28 12:00:26.104663', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1216, 168, 'ORDER', '您的订单【ORD1777348764707】已完成，感谢您的光临！', '2026-04-28 12:00:50.187899', b'1', b'1', '2026-04-28 12:01:40.366456', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1217, 169, 'ORDER', '订单【ORD1777348939309】支付成功，已为您安排制作。', '2026-04-28 12:02:20.578368', b'1', b'1', '2026-04-28 12:02:47.583502', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1218, 169, 'ORDER', '您的订单【ORD1777348939309】商家已接单，正在为您制作中。', '2026-04-28 12:02:30.710960', b'1', b'1', '2026-04-28 12:02:47.583502', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1219, 169, 'ORDER', '您的预约订单【ORD1777348939309】已制作完成，预约取餐时间 12:03，请准时到达取餐口。', '2026-04-28 12:02:32.022882', b'1', b'1', '2026-04-28 12:02:47.583502', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1220, 169, 'ORDER', '您的订单【ORD1777348939309】已完成，感谢您的光临！', '2026-04-28 12:02:49.777368', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1221, 52, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 12:03:06.784335', b'1', b'1', '2026-05-12 09:03:31.272965', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 9);
INSERT INTO `notifications` VALUES (1222, 170, 'ORDER', '订单【ORD1777349017456】支付成功，已为您安排制作。', '2026-04-28 12:03:39.178908', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1223, 170, 'ORDER', '您的订单【ORD1777349017456】商家已接单，正在为您制作中。', '2026-04-28 12:03:50.398436', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1224, 170, 'ORDER', '您的订单【ORD1777349017456】已制作完成，请前往取餐口取餐。', '2026-04-28 12:03:51.446778', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1225, 170, 'ORDER', '您的订单【ORD1777349017456】已完成，感谢您的光临！', '2026-04-28 12:03:52.396297', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1226, 171, 'ORDER', '订单【ORD1777349069483】支付成功，已为您安排制作。', '2026-04-28 12:04:31.103239', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1227, 172, 'ORDER', '订单【ORD1777349086113】支付成功，已为您安排制作。', '2026-04-28 12:04:48.178163', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1228, 171, 'ORDER', '您的订单【ORD1777349069483】商家已接单，正在为您制作中。', '2026-04-28 12:05:24.257509', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1229, 172, 'ORDER', '您的订单【ORD1777349086113】商家已接单，正在为您制作中。', '2026-04-28 12:05:25.270126', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1230, 171, 'ORDER', '您的订单【ORD1777349069483】已制作完成，请前往取餐口取餐。', '2026-04-28 12:05:26.162679', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1231, 171, 'ORDER', '您的订单【ORD1777349069483】已完成，感谢您的光临！', '2026-04-28 12:05:28.107745', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1232, 172, 'ORDER', '您的订单【ORD1777349086113】已制作完成，请前往取餐口取餐。', '2026-04-28 12:05:29.184895', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1233, 172, 'ORDER', '您的订单【ORD1777349086113】已完成，感谢您的光临！', '2026-04-28 12:05:30.012666', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 8);
INSERT INTO `notifications` VALUES (1234, 53, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 12:05:49.666017', b'1', b'1', '2026-05-09 22:16:46.666312', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 5);
INSERT INTO `notifications` VALUES (1235, 54, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 12:06:17.614882', b'1', b'1', '2026-05-09 22:16:46.666312', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 5);
INSERT INTO `notifications` VALUES (1236, 55, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 12:06:48.886122', b'1', b'1', '2026-05-09 22:16:46.666312', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 5);
INSERT INTO `notifications` VALUES (1237, 55, 'REVIEW', '检测到低评分或负面关键词评价，评价ID：55，评分：4.0，评价内容：味道不错，就是分量少了一点', '2026-04-28 12:06:48.933793', b'0', b'0', NULL, 'COMMENT_REPLY', '评价预警', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1238, 56, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 12:07:29.654337', b'1', b'1', '2026-05-12 09:03:31.272965', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 9);
INSERT INTO `notifications` VALUES (1239, 173, 'ORDER', '订单【ORD1777349400015】支付成功，已为您安排制作。', '2026-04-28 12:10:01.854294', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1240, 173, 'ORDER', '您的订单【ORD1777349400015】商家已接单，正在为您制作中。', '2026-04-28 12:10:07.707925', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1241, 173, 'ORDER', '您的订单【ORD1777349400015】已制作完成，请前往取餐口取餐。', '2026-04-28 12:10:08.665961', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1242, 173, 'ORDER', '您的订单【ORD1777349400015】已完成，感谢您的光临！', '2026-04-28 12:10:09.766091', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1243, 57, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-04-28 12:10:23.662329', b'1', b'1', '2026-04-29 13:44:59.139074', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1244, 174, 'ORDER', '订单【ORD1777349472118】支付成功，已为您安排制作。', '2026-04-28 12:11:13.968824', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1245, 174, 'ORDER', '您的订单【ORD1777349472118】商家已接单，正在为您制作中。', '2026-04-28 12:11:19.946393', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1246, 174, 'ORDER', '您的订单【ORD1777349472118】已制作完成，请前往取餐口取餐。', '2026-04-28 12:11:20.868720', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1247, 174, 'ORDER', '您的订单【ORD1777349472118】已完成，感谢您的光临！', '2026-04-28 12:11:21.911337', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1248, 58, 'REVIEW', '感谢您的评价！您获得了 20 积分奖励。', '2026-04-28 12:12:09.549914', b'1', b'1', '2026-04-29 13:44:59.139074', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1249, 175, 'ORDER', '订单【ORD1777349609262】支付成功，已为您安排制作。', '2026-04-28 12:13:30.884268', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1250, 175, 'ORDER', '您的订单【ORD1777349609262】商家已接单，正在为您制作中。', '2026-04-28 12:13:36.430011', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1251, 175, 'ORDER', '您的订单【ORD1777349609262】已制作完成，请前往取餐口取餐。', '2026-04-28 12:13:37.438801', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1252, 175, 'ORDER', '您的订单【ORD1777349609262】已完成，感谢您的光临！', '2026-04-28 12:13:38.341045', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1253, 21, 'ORDER', '您的订单【ORD176889886304220】已制作完成，请前往取餐口取餐。', '2026-04-28 12:13:40.267708', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1254, 27, 'ORDER', '您的订单【ORD176889886312526】已制作完成，请前往取餐口取餐。', '2026-04-28 12:13:41.496023', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1255, 21, 'ORDER', '您的订单【ORD176889886304220】已完成，感谢您的光临！', '2026-04-28 12:13:42.277916', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1256, 27, 'ORDER', '您的订单【ORD176889886312526】已完成，感谢您的光临！', '2026-04-28 12:13:43.114872', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1257, 176, 'ORDER', '订单【ORD1777362912399】支付成功，已为您安排制作。', '2026-04-28 15:55:13.952366', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1258, 176, 'ORDER', '您的订单【ORD1777362912399】商家已接单，正在为您制作中。', '2026-04-28 15:56:27.201671', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1259, 176, 'ORDER', '您的订单【ORD1777362912399】已制作完成，请前往取餐口取餐。', '2026-04-28 15:56:35.310467', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1260, 176, 'ORDER', '您的订单【ORD1777362912399】已完成，感谢您的光临！', '2026-04-28 15:56:36.349062', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1261, 177, 'ORDER', '订单【ORD1777363082934】支付成功，已为您安排制作。', '2026-04-28 15:58:15.882734', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1262, 177, 'ORDER', '您的订单【ORD1777363082934】商家已接单，正在为您制作中。', '2026-04-28 15:58:26.906199', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1263, 177, 'ORDER', '您的订单【ORD1777363082934】已制作完成，请前往取餐口取餐。', '2026-04-28 15:58:28.052049', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1264, 177, 'ORDER', '您的订单【ORD1777363082934】已完成，感谢您的光临！', '2026-04-28 15:58:35.457010', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1265, 178, 'ORDER', '订单【ORD1777363211432】支付成功，已为您安排制作。', '2026-04-28 16:00:12.878600', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1266, 178, 'ORDER', '您的订单【ORD1777363211432】商家已接单，正在为您制作中。', '2026-04-28 16:00:19.583966', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1267, 178, 'ORDER', '您的订单【ORD1777363211432】已制作完成，请前往取餐口取餐。', '2026-04-28 16:00:22.366168', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1268, 178, 'ORDER', '您的订单【ORD1777363211432】已完成，感谢您的光临！', '2026-04-28 16:00:23.330354', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1269, 179, 'ORDER', '订单【ORD1777380840741】支付成功，已为您安排制作。', '2026-04-28 20:54:02.384019', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1270, 179, 'ORDER', '您的订单【ORD1777380840741】商家已接单，正在为您制作中。', '2026-04-28 20:54:09.074573', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1271, 179, 'ORDER', '您的订单【ORD1777380840741】已制作完成，请前往取餐口取餐。', '2026-04-28 20:54:10.011766', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1272, 179, 'ORDER', '您的订单【ORD1777380840741】已完成，感谢您的光临！', '2026-04-28 20:54:11.036134', b'1', b'1', '2026-04-29 13:44:59.139074', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1273, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.043020', b'1', b'1', '2026-04-29 13:44:59.139074', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (1274, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.044107', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (1275, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.046961', b'1', b'1', '2026-05-11 13:16:19.111329', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (1276, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.048322', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (1277, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.050033', b'1', b'1', '2026-05-09 22:16:46.666312', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (1278, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.052456', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (1279, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.056565', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (1280, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.060130', b'1', b'1', '2026-05-12 09:03:31.272965', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (1281, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.061876', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (1282, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.064696', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (1283, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-28 20:54:37.066804', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (1284, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.527402', b'1', b'1', '2026-04-29 13:44:59.139074', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (1285, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.529434', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (1286, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.531459', b'1', b'1', '2026-05-11 13:16:19.111329', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (1287, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.533234', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (1288, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.535618', b'1', b'1', '2026-05-09 22:16:46.666312', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (1289, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.537692', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (1290, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.539406', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (1291, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.541466', b'1', b'1', '2026-05-12 09:03:31.272965', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (1292, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.543707', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (1293, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.545386', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (1294, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:39.547721', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (1295, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.494786', b'1', b'1', '2026-04-29 13:44:59.139074', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (1296, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.496818', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (1297, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.498344', b'1', b'1', '2026-05-11 13:16:19.111329', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (1298, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.500416', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (1299, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.502588', b'1', b'1', '2026-05-09 22:16:46.666312', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (1300, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.503657', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (1301, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.505844', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (1302, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.507892', b'1', b'1', '2026-05-12 09:03:31.272965', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (1303, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.510869', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (1304, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.512014', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (1305, 13, 'PROMOTION', '促销活动「套餐」已开始（2026-04-08 00:00 - 2027-05-28 00:00），快去下单吧！', '2026-04-28 20:54:44.513690', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (1306, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.069468', b'1', b'1', '2026-04-29 13:44:59.139074', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (1307, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.076753', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (1308, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.078600', b'1', b'1', '2026-05-11 13:16:19.111329', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (1309, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.080570', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (1310, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.083795', b'1', b'1', '2026-05-09 22:16:46.666312', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (1311, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.086321', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (1312, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.088370', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (1313, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.089256', b'1', b'1', '2026-05-12 09:03:31.272965', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (1314, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.093089', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (1315, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.095223', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (1316, 18, 'PROMOTION', '促销活动「1」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:42:31.097499', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (1318, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:46.989929', b'1', b'1', '2026-04-29 13:44:59.139074', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (1319, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:46.992591', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (1320, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:46.994902', b'1', b'1', '2026-05-11 13:16:19.111329', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (1321, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:46.995785', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (1322, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:46.995785', b'1', b'1', '2026-05-09 22:16:46.666312', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (1323, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:46.998907', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (1324, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:46.998907', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (1325, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:47.001004', b'1', b'1', '2026-05-12 09:03:31.272965', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (1326, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:47.001762', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (1327, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:47.002802', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (1328, 19, 'PROMOTION', '促销活动「wuzhe」已开始（2026-04-29 00:00 - 2026-05-30 00:00），快去下单吧！', '2026-04-29 13:43:47.004447', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (1330, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.042046', b'1', b'1', '2026-04-29 13:44:59.139074', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (1331, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.044310', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (1332, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.045185', b'1', b'1', '2026-05-11 13:16:19.111329', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (1333, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.046187', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (1334, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.048501', b'1', b'1', '2026-05-09 22:16:46.666312', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (1335, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.048501', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (1336, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.050463', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (1337, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.051719', b'1', b'1', '2026-05-12 09:03:31.272965', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (1338, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.054001', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (1339, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.056015', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (1340, 14, 'PROMOTION', '促销活动「开学促销」已开始（2026-03-25 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-04-29 13:44:08.056777', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 12);
INSERT INTO `notifications` VALUES (1341, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.178433', b'1', b'1', '2026-05-12 00:10:23.788345', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (1342, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.181829', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (1343, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.185258', b'1', b'1', '2026-05-11 13:16:19.111843', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (1344, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.186837', b'1', b'1', '2026-05-09 22:16:46.666312', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (1345, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.189590', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (1346, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.192312', b'1', b'1', '2026-05-12 09:03:31.272965', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (1347, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.195065', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (1348, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.197935', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (1349, 57, 'DISH', '新菜品【广东肠粉】上线啦，快去尝鲜吧！', '2026-05-03 01:46:32.201250', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 12);
INSERT INTO `notifications` VALUES (1354, 190, 'ORDER', '订单【ORD1778336245510】支付成功，已为您安排制作。', '2026-05-09 22:17:27.626824', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1355, 189, 'ORDER', '订单【ORD1778336239365】支付成功，已为您安排制作。', '2026-05-09 22:17:29.663709', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1356, 185, 'ORDER', '您的订单【ORD1778336190286】已成功取消。', '2026-05-09 22:17:33.259559', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已取消', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1357, 188, 'ORDER', '订单【ORD1778336230674】支付成功，已为您安排制作。', '2026-05-09 22:18:07.620602', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1358, 188, 'ORDER', '您的订单【ORD1778336230674】商家已接单，正在为您制作中。', '2026-05-09 22:18:42.277364', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1359, 188, 'ORDER', '您的订单【ORD1778336230674】已制作完成，请前往取餐口取餐。', '2026-05-09 22:18:44.243531', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1360, 189, 'ORDER', '您的订单【ORD1778336239365】商家已接单，正在为您制作中。', '2026-05-09 22:18:45.638542', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1361, 188, 'ORDER', '您的订单【ORD1778336230674】已完成，感谢您的光临！', '2026-05-09 22:19:14.835518', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1362, 61, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-09 22:19:37.293010', b'0', b'0', NULL, 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 5);
INSERT INTO `notifications` VALUES (1363, 191, 'ORDER', '您的订单【ORD1778336397294】已成功取消。', '2026-05-09 22:20:01.073430', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已取消', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1364, 192, 'ORDER', '订单【ORD1778336406258】支付成功，已为您安排制作。', '2026-05-09 22:20:07.665117', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1365, 196, 'ORDER', '订单【ORD1778336431153】支付成功，已为您安排制作。', '2026-05-09 22:20:39.780069', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1366, 200, 'ORDER', '订单【ORD1778336499511】支付成功，已为您安排制作。', '2026-05-09 22:25:27.848226', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1367, 200, 'ORDER', '您的订单【ORD1778336499511】商家已接单，正在为您制作中。', '2026-05-09 22:26:05.370249', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1368, 200, 'ORDER', '您的订单【ORD1778336499511】已制作完成，请前往取餐口取餐。', '2026-05-09 22:26:08.376095', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1369, 196, 'ORDER', '您的订单【ORD1778336431153】商家已接单，正在为您制作中。', '2026-05-09 22:26:10.921845', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1370, 196, 'ORDER', '您的订单【ORD1778336431153】已制作完成，请前往取餐口取餐。', '2026-05-09 22:26:12.178952', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1371, 193, 'ORDER', '您的订单【ORD1778336411403】已成功取消。', '2026-05-09 22:26:35.946273', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已取消', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1372, 187, 'ORDER', '您的订单【ORD1778336223878】已成功取消。', '2026-05-09 22:26:37.415734', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已取消', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1373, 186, 'ORDER', '您的订单【ORD1778336194025】已成功取消。', '2026-05-09 22:26:38.427665', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已取消', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1374, 201, 'ORDER', '订单【ORD1778336814299】支付成功，已为您安排制作。', '2026-05-09 22:26:56.667868', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1375, 206, 'ORDER', '订单【ORD1778336842472】支付成功，已为您安排制作。', '2026-05-09 22:27:27.965703', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1376, 209, 'ORDER', '订单【ORD1778336868057】支付成功，已为您安排制作。', '2026-05-09 22:27:50.184105', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 11);
INSERT INTO `notifications` VALUES (1377, 114, 'ORDER', '您的订单【ORD1773203087685】商家已接单，正在为您制作中。', '2026-05-09 22:30:01.022818', b'1', b'1', '2026-05-11 13:16:19.111843', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (1378, 190, 'ORDER', '您的订单【ORD1778336245510】商家已接单，正在为您制作中。', '2026-05-09 22:30:02.247644', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1379, 192, 'ORDER', '您的订单【ORD1778336406258】商家已接单，正在为您制作中。', '2026-05-09 22:30:03.312517', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1380, 114, 'ORDER', '您的订单【ORD1773203087685】已制作完成，请前往取餐口取餐。', '2026-05-09 22:30:17.657511', b'1', b'1', '2026-05-11 13:16:19.111843', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (1381, 189, 'ORDER', '您的订单【ORD1778336239365】已制作完成，请前往取餐口取餐。', '2026-05-09 22:30:18.652968', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1382, 207, 'ORDER', '订单【ORD1778336852538】支付成功，已为您安排制作。', '2026-05-09 22:30:42.710692', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1383, 205, 'ORDER', '订单【ORD1778336835624】支付成功，已为您安排制作。', '2026-05-09 22:30:44.610688', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1384, 204, 'ORDER', '订单【ORD1778336829866】支付成功，已为您安排制作。', '2026-05-09 22:30:46.038829', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1385, 113, 'ORDER', '您的订单【ORD1772677145008】商家已接单，正在为您制作中。', '2026-05-09 22:31:12.470400', b'1', b'1', '2026-05-12 00:10:23.788345', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1386, 201, 'ORDER', '您的订单【ORD1778336814299】商家已接单，正在为您制作中。', '2026-05-09 22:31:13.564465', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1387, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.151913', b'1', b'1', '2026-05-12 00:10:23.788345', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 1);
INSERT INTO `notifications` VALUES (1388, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.154816', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 2);
INSERT INTO `notifications` VALUES (1389, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.156037', b'1', b'1', '2026-05-11 13:16:19.111843', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 3);
INSERT INTO `notifications` VALUES (1390, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.157641', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 4);
INSERT INTO `notifications` VALUES (1391, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.160317', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 5);
INSERT INTO `notifications` VALUES (1392, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.162071', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 7);
INSERT INTO `notifications` VALUES (1393, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.163152', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 8);
INSERT INTO `notifications` VALUES (1394, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.163152', b'1', b'1', '2026-05-12 09:03:31.272965', 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 9);
INSERT INTO `notifications` VALUES (1395, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.165876', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 10);
INSERT INTO `notifications` VALUES (1396, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.168655', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 11);
INSERT INTO `notifications` VALUES (1397, 20, 'PROMOTION', '促销活动「主食满20减5」已开始（2026-05-10 00:00 - 2026-06-27 00:00），快去下单吧！', '2026-05-10 16:43:02.168655', b'0', b'0', NULL, 'PROMOTION_START', '促销活动开始提醒', 'PROMOTION', 25);
INSERT INTO `notifications` VALUES (1398, 212, 'ORDER', '订单【ORD1778402591861】支付成功，已为您安排制作。', '2026-05-10 16:43:16.425699', b'1', b'1', '2026-05-12 00:10:23.788345', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1399, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.791853', b'1', b'1', '2026-05-12 00:10:23.788345', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (1400, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.793284', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (1401, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.795161', b'1', b'1', '2026-05-11 13:16:19.111843', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (1402, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.796060', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 4);
INSERT INTO `notifications` VALUES (1403, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.797393', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (1404, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.798402', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 7);
INSERT INTO `notifications` VALUES (1405, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.799407', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (1406, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.800471', b'1', b'1', '2026-05-12 09:03:31.272965', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (1407, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.801406', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 25);
INSERT INTO `notifications` VALUES (1408, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.803027', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (1409, 10, 'DISH', '菜品【包子】已重新上架，快去看看吧！', '2026-05-10 16:44:18.803534', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (1410, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.093857', b'1', b'1', '2026-05-12 00:10:23.788345', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (1411, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.094588', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (1412, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.096184', b'1', b'1', '2026-05-11 13:16:19.111843', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (1413, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.097189', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 4);
INSERT INTO `notifications` VALUES (1414, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.099035', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (1415, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.100395', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 7);
INSERT INTO `notifications` VALUES (1416, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.101769', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (1417, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.101769', b'1', b'1', '2026-05-12 09:03:31.272965', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (1418, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.104163', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 25);
INSERT INTO `notifications` VALUES (1419, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.104493', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (1420, 2, 'DISH', '菜品【宫保鸡丁】已重新上架，快去看看吧！', '2026-05-10 16:45:14.105998', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (1421, 114, 'ORDER', '您的订单【ORD1773203087685】已完成，感谢您的光临！', '2026-05-11 13:16:55.513086', b'1', b'1', '2026-05-12 08:54:06.201330', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (1422, 62, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-11 13:17:03.662795', b'1', b'1', '2026-05-12 08:54:06.201330', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 3);
INSERT INTO `notifications` VALUES (1423, 63, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-11 13:17:19.966317', b'1', b'1', '2026-05-12 08:54:06.201330', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 3);
INSERT INTO `notifications` VALUES (1424, 213, 'ORDER', '订单【ORD1778476683685】支付成功，已为您安排制作。', '2026-05-11 13:18:06.955515', b'1', b'1', '2026-05-12 08:54:06.201330', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 3);
INSERT INTO `notifications` VALUES (1425, 214, 'ORDER', '订单【ORD1778476731190】支付成功，已为您安排制作。', '2026-05-11 13:18:52.746424', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1426, 216, 'ORDER', '订单【ORD1778476776919】支付成功，已为您安排制作。', '2026-05-11 13:19:39.641873', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1427, 217, 'ORDER', '订单【ORD1778476796769】支付成功，已为您安排制作。', '2026-05-11 13:19:58.619543', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1428, 195, 'ORDER', '订单【ORD1778336424497】支付成功，已为您安排制作。', '2026-05-11 13:20:01.411267', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1429, 217, 'ORDER', '您的订单【ORD1778476796769】商家已接单，正在为您制作中。', '2026-05-11 13:20:36.694638', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1430, 216, 'ORDER', '您的订单【ORD1778476776919】商家已接单，正在为您制作中。', '2026-05-11 13:20:38.136163', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1431, 217, 'ORDER', '您的订单【ORD1778476796769】已制作完成，请前往取餐口取餐。', '2026-05-11 13:20:40.876926', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1432, 217, 'ORDER', '您的订单【ORD1778476796769】已完成，感谢您的光临！', '2026-05-11 13:20:42.415433', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1433, 201, 'ORDER', '您的订单【ORD1778336814299】已制作完成，请前往取餐口取餐。', '2026-05-11 13:20:45.140433', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1434, 201, 'ORDER', '您的订单【ORD1778336814299】已完成，感谢您的光临！', '2026-05-11 13:20:46.801395', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1435, 214, 'ORDER', '您的订单【ORD1778476731190】商家已接单，正在为您制作中。', '2026-05-11 13:20:50.093772', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1436, 214, 'ORDER', '您的订单【ORD1778476731190】已制作完成，请前往取餐口取餐。', '2026-05-11 13:20:51.371784', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1437, 214, 'ORDER', '您的订单【ORD1778476731190】已完成，感谢您的光临！', '2026-05-11 13:20:52.570493', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1438, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.857043', b'1', b'1', '2026-05-12 00:10:23.788345', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (1439, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.858460', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (1440, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.858966', b'1', b'1', '2026-05-12 08:54:06.201330', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (1441, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.860502', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 4);
INSERT INTO `notifications` VALUES (1442, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.861190', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (1443, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.862202', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 7);
INSERT INTO `notifications` VALUES (1444, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.862202', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (1445, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.863889', b'1', b'1', '2026-05-12 09:03:31.272965', 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (1446, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.863889', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 25);
INSERT INTO `notifications` VALUES (1447, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.864931', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (1448, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-11 13:21:48.864931', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (1449, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.315784', b'1', b'1', '2026-05-12 00:10:23.788345', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (1450, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.317926', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (1451, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.319249', b'1', b'1', '2026-05-12 08:54:06.201330', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (1452, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.320301', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 4);
INSERT INTO `notifications` VALUES (1453, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.321318', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (1454, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.323388', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 7);
INSERT INTO `notifications` VALUES (1455, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.324519', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (1456, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.326050', b'1', b'1', '2026-05-12 09:03:31.272965', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (1457, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.327064', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 25);
INSERT INTO `notifications` VALUES (1458, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.328603', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (1459, 58, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 00:08:23.329618', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (1464, 65, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-12 00:08:55.916604', b'1', b'1', '2026-05-12 00:10:23.788345', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1465, 219, 'ORDER', '订单【ORD1778515758294】支付成功，已为您安排制作。', '2026-05-12 00:09:19.624032', b'1', b'1', '2026-05-12 00:10:23.788345', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1466, 219, 'ORDER', '您的订单【ORD1778515758294】商家已接单，正在为您制作中。', '2026-05-12 00:09:24.307686', b'1', b'1', '2026-05-12 00:10:23.788345', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1467, 219, 'ORDER', '您的订单【ORD1778515758294】已制作完成，请前往取餐口取餐。', '2026-05-12 00:09:25.876561', b'1', b'1', '2026-05-12 00:10:23.788345', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1468, 219, 'ORDER', '您的订单【ORD1778515758294】已完成，感谢您的光临！', '2026-05-12 00:09:26.911651', b'1', b'1', '2026-05-12 00:10:23.788345', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1469, 66, 'REVIEW', '感谢您的评价！您获得了 30 积分奖励。', '2026-05-12 00:09:51.084860', b'1', b'1', '2026-05-12 00:10:23.788345', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1470, 58, 'REVIEW', '食堂回复了您的评价：感谢支持', '2026-05-12 00:10:10.605493', b'1', b'1', '2026-05-12 00:10:23.788345', 'COMMENT_REPLY', '您的评价有新回复', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1471, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.506496', b'1', b'1', '2026-05-12 08:47:14.457712', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 1);
INSERT INTO `notifications` VALUES (1472, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.510863', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 2);
INSERT INTO `notifications` VALUES (1473, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.512586', b'1', b'1', '2026-05-12 08:54:06.201330', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 3);
INSERT INTO `notifications` VALUES (1474, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.515511', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 4);
INSERT INTO `notifications` VALUES (1475, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.517337', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 5);
INSERT INTO `notifications` VALUES (1476, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.521163', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 7);
INSERT INTO `notifications` VALUES (1477, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.525262', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 8);
INSERT INTO `notifications` VALUES (1478, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.528361', b'1', b'1', '2026-05-12 09:03:31.272965', 'DISH_ON_SHELF', '新菜品上线', 'DISH', 9);
INSERT INTO `notifications` VALUES (1479, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.530793', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 25);
INSERT INTO `notifications` VALUES (1480, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.533826', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 10);
INSERT INTO `notifications` VALUES (1481, 59, 'DISH', '新菜品【广式肠粉】上线啦，快去尝鲜吧！', '2026-05-12 08:46:35.536361', b'0', b'0', NULL, 'DISH_ON_SHELF', '新菜品上线', 'DISH', 11);
INSERT INTO `notifications` VALUES (1482, 221, 'ORDER', '订单【ORD1778546872490】支付成功，已为您安排制作。', '2026-05-12 08:47:54.204791', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1483, 220, 'ORDER', '订单【ORD1778546863432】支付成功，已为您安排制作。', '2026-05-12 08:47:55.931638', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1484, 222, 'ORDER', '订单【ORD1778546880103】支付成功，已为您安排制作。', '2026-05-12 08:48:01.762877', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1485, 224, 'ORDER', '订单【ORD1778546911014】支付成功，已为您安排制作。', '2026-05-12 08:48:33.458775', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1486, 223, 'ORDER', '订单【ORD1778546902843】支付成功，已为您安排制作。', '2026-05-12 08:48:35.611647', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1487, 220, 'ORDER', '您的订单【ORD1778546863432】商家已接单，正在为您制作中。', '2026-05-12 08:48:46.472869', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1488, 221, 'ORDER', '您的订单【ORD1778546872490】商家已接单，正在为您制作中。', '2026-05-12 08:48:47.491539', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1489, 220, 'ORDER', '您的订单【ORD1778546863432】已制作完成，请前往取餐口取餐。', '2026-05-12 08:48:48.515380', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1490, 221, 'ORDER', '您的订单【ORD1778546872490】已制作完成，请前往取餐口取餐。', '2026-05-12 08:48:49.488737', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1491, 220, 'ORDER', '您的订单【ORD1778546863432】已完成，感谢您的光临！', '2026-05-12 08:48:50.424792', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1492, 221, 'ORDER', '您的订单【ORD1778546872490】已完成，感谢您的光临！', '2026-05-12 08:48:51.344180', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1493, 222, 'ORDER', '您的订单【ORD1778546880103】商家已接单，正在为您制作中。', '2026-05-12 08:48:54.327616', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1494, 223, 'ORDER', '您的订单【ORD1778546902843】商家已接单，正在为您制作中。', '2026-05-12 08:48:56.188557', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1495, 215, 'ORDER', '您的订单【ORD1778476749651】已成功取消。', '2026-05-12 08:49:00.003357', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已取消', 'RESERVATION', 5);
INSERT INTO `notifications` VALUES (1496, 224, 'ORDER', '您的订单【ORD1778546911014】商家已接单，正在为您制作中。', '2026-05-12 08:49:01.474601', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1497, 224, 'ORDER', '您的订单【ORD1778546911014】已制作完成，请前往取餐口取餐。', '2026-05-12 08:49:02.796774', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1498, 223, 'ORDER', '您的订单【ORD1778546902843】已制作完成，请前往取餐口取餐。', '2026-05-12 08:49:04.149553', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1499, 222, 'ORDER', '您的订单【ORD1778546880103】已制作完成，请前往取餐口取餐。', '2026-05-12 08:49:05.441407', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1500, 222, 'ORDER', '您的订单【ORD1778546880103】已完成，感谢您的光临！', '2026-05-12 08:49:06.964234', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 4);
INSERT INTO `notifications` VALUES (1501, 223, 'ORDER', '您的订单【ORD1778546902843】已完成，感谢您的光临！', '2026-05-12 08:49:10.854923', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1502, 224, 'ORDER', '您的订单【ORD1778546911014】已完成，感谢您的光临！', '2026-05-12 08:49:12.279992', b'1', b'1', '2026-05-12 09:03:31.272965', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 9);
INSERT INTO `notifications` VALUES (1503, 225, 'ORDER', '订单【ORD1778547000562】支付成功，已为您安排制作。', '2026-05-12 08:50:01.949167', b'1', b'1', '2026-05-12 08:53:54.151068', 'ORDER_STATUS_CHANGE', '支付成功', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1504, 225, 'ORDER', '您的订单【ORD1778547000562】商家已接单，正在为您制作中。', '2026-05-12 08:50:24.931921', b'1', b'1', '2026-05-12 08:53:54.151068', 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1505, 225, 'ORDER', '您的订单【ORD1778547000562】已制作完成，请前往取餐口取餐。', '2026-05-12 08:50:26.106404', b'1', b'1', '2026-05-12 08:53:54.151068', 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1506, 225, 'ORDER', '您的订单【ORD1778547000562】已完成，感谢您的光临！', '2026-05-12 08:50:27.029196', b'1', b'1', '2026-05-12 08:53:54.151068', 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 1);
INSERT INTO `notifications` VALUES (1507, 29, 'DISH', '【永州血鸭】库存极低（剩余 4 份，销量已达剩余库存的80%），请立即补货', '2026-05-12 08:50:39.849343', b'1', b'1', '2026-05-12 08:50:51.780116', 'INVENTORY_WARNING', '库存预警', 'WARNING', 1);
INSERT INTO `notifications` VALUES (1508, 29, 'DISH', '【永州血鸭】库存极低（剩余 4 份，销量已达剩余库存的80%），请立即补货', '2026-05-12 08:50:39.859619', b'0', b'0', NULL, 'INVENTORY_WARNING', '库存预警', 'WARNING', 2);
INSERT INTO `notifications` VALUES (1509, 29, 'DISH', '【永州血鸭】库存极低（剩余 4 份，销量已达剩余库存的80%），请立即补货', '2026-05-12 08:50:56.335000', b'1', b'1', '2026-05-12 08:51:48.432765', 'INVENTORY_WARNING', '库存预警', 'WARNING', 1);
INSERT INTO `notifications` VALUES (1510, 29, 'DISH', '【永州血鸭】库存极低（剩余 4 份，销量已达剩余库存的80%），请立即补货', '2026-05-12 08:50:56.347933', b'0', b'0', NULL, 'INVENTORY_WARNING', '库存预警', 'WARNING', 2);
INSERT INTO `notifications` VALUES (1511, 67, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-12 08:54:40.208342', b'1', b'1', '2026-05-12 08:54:43.811697', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 3);
INSERT INTO `notifications` VALUES (1512, 68, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-12 08:59:19.392750', b'1', b'1', '2026-05-12 09:03:31.272965', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 9);
INSERT INTO `notifications` VALUES (1513, 68, 'REVIEW', '检测到低评分或负面关键词评价，评价ID：68，评分：2.3，评价内容：不好吃，不要点', '2026-05-12 08:59:19.457592', b'0', b'0', NULL, 'COMMENT_REPLY', '评价预警', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1514, 68, 'REVIEW', '食堂回复了您的评价：不好意思，给您带来了不好的体验', '2026-05-12 09:00:19.236504', b'1', b'1', '2026-05-12 09:03:31.272965', 'COMMENT_REPLY', '您的评价有新回复', 'COMMENT', 9);
INSERT INTO `notifications` VALUES (1515, 69, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-12 09:03:28.669301', b'1', b'1', '2026-05-12 09:03:31.272965', 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 9);
INSERT INTO `notifications` VALUES (1516, 69, 'REVIEW', '检测到低评分或负面关键词评价，评价ID：69，评分：2.0，评价内容：差评差评', '2026-05-12 09:03:28.730874', b'0', b'0', NULL, 'COMMENT_REPLY', '评价预警', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1517, 70, 'REVIEW', '感谢您的评价！您获得了 10 积分奖励。', '2026-05-12 09:04:29.824246', b'0', b'0', NULL, 'COMMENT_REPLY', '评价奖励到账', 'COMMENT', 9);
INSERT INTO `notifications` VALUES (1518, 70, 'REVIEW', '检测到低评分或负面关键词评价，评价ID：70，评分：2.0，评价内容：真难吃', '2026-05-12 09:04:29.900390', b'0', b'0', NULL, 'COMMENT_REPLY', '评价预警', 'COMMENT', 1);
INSERT INTO `notifications` VALUES (1519, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.699251', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 1);
INSERT INTO `notifications` VALUES (1520, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.712967', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 2);
INSERT INTO `notifications` VALUES (1521, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.712967', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 3);
INSERT INTO `notifications` VALUES (1522, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.715716', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 4);
INSERT INTO `notifications` VALUES (1523, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.715716', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 5);
INSERT INTO `notifications` VALUES (1524, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.715716', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 7);
INSERT INTO `notifications` VALUES (1525, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.715716', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 8);
INSERT INTO `notifications` VALUES (1526, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.718527', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 9);
INSERT INTO `notifications` VALUES (1527, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.718527', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 10);
INSERT INTO `notifications` VALUES (1528, 1, 'DISH', '菜品【红烧肉】已重新上架，快去看看吧！', '2026-05-12 11:36:36.718527', b'0', b'0', NULL, 'DISH_ON_SHELF', '菜品重新上架', 'DISH', 11);
INSERT INTO `notifications` VALUES (1529, 194, 'ORDER', '您的订单【ORD1778336417403】已成功取消。', '2026-05-12 11:37:23.893551', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已取消', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1530, 195, 'ORDER', '您的订单【ORD1778336424497】商家已接单，正在为您制作中。', '2026-05-12 11:37:37.206868', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 7);
INSERT INTO `notifications` VALUES (1531, 206, 'ORDER', '您的订单【ORD1778336842472】商家已接单，正在为您制作中。', '2026-05-12 11:37:49.247444', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单开始制作', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1532, 206, 'ORDER', '您的订单【ORD1778336842472】已制作完成，请前往取餐口取餐。', '2026-05-12 11:37:50.442600', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '取餐提醒', 'RESERVATION', 10);
INSERT INTO `notifications` VALUES (1533, 206, 'ORDER', '您的订单【ORD1778336842472】已完成，感谢您的光临！', '2026-05-12 11:38:05.275764', b'0', b'0', NULL, 'ORDER_STATUS_CHANGE', '订单已完成', 'RESERVATION', 10);

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
) ENGINE = InnoDB AUTO_INCREMENT = 350 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (34, 19, 2, '2026-01-20 16:47:43', 1, 10.00, 10.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1769497034556', '2026-01-27 14:57:15', '2025-12-24 05:22:43', '2026-02-03 22:41:42', NULL, NULL);
INSERT INTO `order_items` VALUES (35, 19, 25, '2026-01-20 16:47:43', 2, 58.00, 116.00, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1769497034556', '2026-01-27 14:57:15', '2025-12-24 05:22:43', '2026-02-03 22:41:42', NULL, NULL);
INSERT INTO `order_items` VALUES (36, 20, 21, '2026-01-20 16:47:43', 2, 15.00, 30.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863029190', '2025-12-24 23:53:43', '2025-12-24 23:48:43', '2026-03-25 21:47:06', NULL, NULL);
INSERT INTO `order_items` VALUES (37, 20, 30, '2026-01-20 16:47:43', 1, 48.00, 48.00, NULL, NULL, 22, '浙菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863029191', '2025-12-24 23:53:43', '2025-12-24 23:48:43', '2026-03-25 21:47:06', NULL, NULL);
INSERT INTO `order_items` VALUES (38, 20, 1, '2026-01-20 16:47:43', 2, 12.00, 24.00, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863029192', '2025-12-24 23:53:43', '2025-12-24 23:48:43', '2026-03-25 21:47:06', NULL, NULL);
INSERT INTO `order_items` VALUES (39, 21, 24, '2026-01-20 16:47:43', 3, 68.00, 204.00, NULL, NULL, 27, '苏菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863042200', '2026-01-16 14:25:43', '2026-01-16 14:20:43', '2026-04-28 12:13:40', NULL, NULL);
INSERT INTO `order_items` VALUES (40, 21, 23, '2026-01-20 16:47:43', 3, 10.00, 30.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863042201', '2026-01-16 14:25:43', '2026-01-16 14:20:43', '2026-04-28 12:13:40', NULL, NULL);
INSERT INTO `order_items` VALUES (51, 27, 2, '2026-01-20 16:47:43', 3, 10.00, 30.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863125260', '2025-12-31 14:19:43', '2025-12-31 14:14:43', '2026-04-28 12:13:41', NULL, NULL);
INSERT INTO `order_items` VALUES (52, 27, 9, '2026-01-20 16:47:43', 1, 16.00, 16.00, NULL, NULL, 23, '清真窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863125261', '2025-12-31 14:19:43', '2025-12-31 14:14:43', '2026-04-28 12:13:41', NULL, NULL);
INSERT INTO `order_items` VALUES (54, 29, 6, '2026-01-20 16:47:43', 2, 3.00, 6.00, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863146280', '2025-12-31 10:18:43', '2025-12-31 10:13:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (55, 29, 28, '2026-01-20 16:47:43', 1, 32.00, 32.00, NULL, NULL, 5, '湘菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863146281', '2025-12-31 10:18:43', '2025-12-31 10:13:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (56, 29, 27, '2026-01-20 16:47:43', 3, 58.00, 174.00, NULL, NULL, 24, '湘菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1768898863146282', '2025-12-31 10:18:43', '2025-12-31 10:13:43', '2026-01-20 16:47:43', NULL, NULL);
INSERT INTO `order_items` VALUES (95, 69, 1, '2026-02-06 22:23:12', 3, 8.40, 25.20, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770387794189', '2026-02-06 22:23:14', '2026-02-06 22:23:13', '2026-02-06 22:23:21', NULL, NULL);
INSERT INTO `order_items` VALUES (96, 70, 2, '2026-02-06 22:23:41', 42, 7.00, 294.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770387823433', '2026-02-06 22:23:43', '2026-02-06 22:23:42', '2026-02-06 22:23:52', NULL, NULL);
INSERT INTO `order_items` VALUES (103, 75, 25, '2026-02-07 23:24:09', 50, 40.60, 2030.00, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770477850469', '2026-02-07 23:24:10', '2026-02-07 23:24:09', '2026-02-07 23:24:17', NULL, NULL);
INSERT INTO `order_items` VALUES (130, 94, 7, '2026-02-11 20:30:10', 1, 7.00, 7.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'ALIPAY', 'TX1770813013695', '2026-02-11 20:30:14', '2026-02-11 20:30:11', '2026-02-11 20:30:21', b'0', NULL);
INSERT INTO `order_items` VALUES (137, 101, 7, '2026-02-12 16:10:55', 1, 8.00, 8.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1770883857106', '2026-02-12 16:10:57', '2026-02-12 16:10:56', '2026-02-12 16:11:07', b'0', NULL);
INSERT INTO `order_items` VALUES (153, 112, 2, '2026-02-21 20:14:37', 1, 6.65, 6.65, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771676080082', '2026-02-21 20:14:40', '2026-02-21 20:14:38', '2026-02-21 20:14:49', b'0', NULL);
INSERT INTO `order_items` VALUES (154, 112, 6, '2026-02-21 20:14:37', 1, 2.10, 2.10, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1771676080082', '2026-02-21 20:14:40', '2026-02-21 20:14:38', '2026-02-21 20:14:49', b'0', NULL);
INSERT INTO `order_items` VALUES (155, 113, 3, '2026-03-05 10:19:05', 1, 8.00, 8.00, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'ALIPAY', 'TX1772677152236', '2026-03-05 10:19:12', '2026-03-05 10:19:05', '2026-05-09 22:31:12', b'0', NULL);
INSERT INTO `order_items` VALUES (156, 114, 2, '2026-03-11 12:24:47', 1, 10.00, 10.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1774234548810', '2026-03-23 10:55:49', '2026-03-11 12:24:48', '2026-05-09 22:30:18', b'0', NULL);
INSERT INTO `order_items` VALUES (162, 119, 3, '2026-03-23 11:44:11', 1, 5.52, 5.52, NULL, NULL, 20, '川菜窗口', '一楼南侧', NULL, NULL, 'WECHAT', 'TX1774237453290', '2026-03-23 11:44:13', '2026-03-23 11:44:11', '2026-03-23 11:44:30', b'0', 8);
INSERT INTO `order_items` VALUES (163, 119, 5, '2026-03-23 11:44:11', 1, 3.45, 3.45, NULL, NULL, 15, '特色菜窗口', '二楼西侧', NULL, NULL, 'WECHAT', 'TX1774237453290', '2026-03-23 11:44:13', '2026-03-23 11:44:11', '2026-03-23 11:44:30', b'0', 8);
INSERT INTO `order_items` VALUES (164, 119, 14, '2026-03-23 11:44:11', 1, 11.03, 11.03, NULL, NULL, 26, '粤菜窗口', '二楼南侧', NULL, NULL, 'WECHAT', 'TX1774237453290', '2026-03-23 11:44:13', '2026-03-23 11:44:11', '2026-03-23 11:44:30', b'0', 8);
INSERT INTO `order_items` VALUES (165, 120, 3, '2026-03-23 11:51:07', 1, 5.52, 5.52, NULL, NULL, 20, '川菜窗口', '一楼南侧', NULL, NULL, 'WECHAT', 'TX1774237869568', '2026-03-23 11:51:10', '2026-03-23 11:51:08', '2026-03-23 11:51:18', b'0', 8);
INSERT INTO `order_items` VALUES (166, 120, 5, '2026-03-23 11:51:07', 1, 3.45, 3.45, NULL, NULL, 15, '特色菜窗口', '二楼西侧', NULL, NULL, 'WECHAT', 'TX1774237869568', '2026-03-23 11:51:10', '2026-03-23 11:51:08', '2026-03-23 11:51:18', b'0', 8);
INSERT INTO `order_items` VALUES (167, 120, 14, '2026-03-23 11:51:07', 1, 11.03, 11.03, NULL, NULL, 26, '粤菜窗口', '二楼南侧', NULL, NULL, 'WECHAT', 'TX1774237869568', '2026-03-23 11:51:10', '2026-03-23 11:51:08', '2026-03-23 11:51:18', b'0', 8);
INSERT INTO `order_items` VALUES (168, 121, 1, '2026-03-25 21:22:46', 60, 12.00, 720.00, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1774444968525', '2026-03-25 21:22:49', '2026-03-25 21:22:47', '2026-03-25 21:23:02', b'0', NULL);
INSERT INTO `order_items` VALUES (173, 124, 18, '2026-03-25 21:26:27', 69, 42.00, 2898.00, NULL, NULL, 25, '特色菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1774445188741', '2026-03-25 21:26:29', '2026-03-25 21:26:27', '2026-03-25 21:26:56', b'0', NULL);
INSERT INTO `order_items` VALUES (178, 128, 23, '2026-03-28 19:58:26', 50, 8.00, 400.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1774699107992', '2026-03-28 19:58:28', '2026-03-28 19:58:26', '2026-03-28 19:58:34', b'0', NULL);
INSERT INTO `order_items` VALUES (181, 131, 2, '2026-04-04 16:44:42', 1, 8.00, 8.00, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1775292284765', '2026-04-04 16:44:45', '2026-04-04 16:44:43', '2026-04-04 16:49:58', b'0', NULL);
INSERT INTO `order_items` VALUES (182, 132, 1, '2026-04-04 16:45:53', 1, 9.60, 9.60, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1775292356074', '2026-04-04 16:45:56', '2026-04-04 16:45:53', '2026-04-04 16:50:00', b'0', NULL);
INSERT INTO `order_items` VALUES (191, 139, 8, '2026-04-27 14:45:04', 70, 16.00, 1120.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777272305431', '2026-04-27 14:45:05', '2026-04-27 14:45:04', '2026-04-27 14:45:18', b'0', NULL);
INSERT INTO `order_items` VALUES (207, 152, 1, '2026-04-27 16:44:01', 1, 9.60, 9.60, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777279442884', '2026-04-27 16:44:03', '2026-04-27 16:44:01', '2026-04-27 16:45:13', b'0', NULL);
INSERT INTO `order_items` VALUES (208, 153, 25, '2026-04-27 16:45:35', 1, 46.40, 46.40, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777279536894', '2026-04-27 16:45:37', '2026-04-27 16:45:35', '2026-04-27 16:45:49', b'0', NULL);
INSERT INTO `order_items` VALUES (218, 162, 4, '2026-04-28 11:18:10', 1, 5.60, 5.60, NULL, NULL, 6, '特色菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'CARD', 'TX1777346294293', '2026-04-28 11:18:14', '2026-04-28 11:18:11', '2026-04-28 11:18:21', b'0', NULL);
INSERT INTO `order_items` VALUES (219, 162, 10, '2026-04-28 11:18:10', 1, 1.60, 1.60, NULL, NULL, 3, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'CARD', 'TX1777346294293', '2026-04-28 11:18:14', '2026-04-28 11:18:11', '2026-04-28 11:18:21', b'0', NULL);
INSERT INTO `order_items` VALUES (220, 162, 11, '2026-04-28 11:18:10', 1, 1.20, 1.20, NULL, NULL, 13, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'CARD', 'TX1777346294293', '2026-04-28 11:18:14', '2026-04-28 11:18:11', '2026-04-28 11:18:21', b'0', NULL);
INSERT INTO `order_items` VALUES (221, 162, 22, '2026-04-28 11:18:10', 1, 9.60, 9.60, NULL, NULL, 9, '面食窗口', '二楼东侧', 'IMMEDIATE', NULL, 'CARD', 'TX1777346294293', '2026-04-28 11:18:14', '2026-04-28 11:18:11', '2026-04-28 11:18:21', b'0', NULL);
INSERT INTO `order_items` VALUES (222, 163, 31, '2026-04-28 11:41:02', 1, 54.40, 54.40, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777347664736', '2026-04-28 11:41:05', '2026-04-28 11:41:03', '2026-04-28 11:41:20', b'0', NULL);
INSERT INTO `order_items` VALUES (223, 164, 9, '2026-04-28 11:56:52', 1, 12.80, 12.80, NULL, NULL, 23, '清真窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777348613615', '2026-04-28 11:56:54', '2026-04-28 11:56:52', '2026-04-28 11:56:59', b'0', NULL);
INSERT INTO `order_items` VALUES (224, 165, 2, '2026-04-28 11:58:10', 1, 7.60, 7.60, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777348693392', '2026-04-28 11:58:13', '2026-04-28 11:58:10', '2026-04-28 11:58:21', b'0', NULL);
INSERT INTO `order_items` VALUES (225, 166, 12, '2026-04-28 11:58:54', 1, 22.40, 22.40, NULL, NULL, 2, '川菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777348800624', '2026-04-28 12:00:01', '2026-04-28 11:58:54', '2026-04-28 12:00:22', b'0', NULL);
INSERT INTO `order_items` VALUES (226, 167, 26, '2026-04-28 11:59:02', 1, 17.60, 17.60, NULL, NULL, 16, '盖浇饭窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777348798907', '2026-04-28 11:59:59', '2026-04-28 11:59:02', '2026-04-28 12:00:25', b'0', NULL);
INSERT INTO `order_items` VALUES (227, 168, 16, '2026-04-28 11:59:24', 1, 25.60, 25.60, NULL, '2026-04-28 12:00:02', 8, '粤菜窗口', '三楼东侧', 'RESERVATION', NULL, 'WECHAT', 'TX1777348767246', '2026-04-28 11:59:27', '2026-04-28 11:59:25', '2026-04-28 12:00:18', b'0', NULL);
INSERT INTO `order_items` VALUES (228, 169, 19, '2026-04-28 12:02:19', 1, 38.40, 38.40, NULL, '2026-04-28 12:03:00', 10, '鲁菜窗口', '一楼东侧', 'RESERVATION', NULL, 'WECHAT', 'TX1777348940552', '2026-04-28 12:02:21', '2026-04-28 12:02:19', '2026-04-28 12:02:32', b'0', NULL);
INSERT INTO `order_items` VALUES (229, 170, 17, '2026-04-28 12:03:37', 1, 28.00, 28.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349019156', '2026-04-28 12:03:39', '2026-04-28 12:03:37', '2026-04-28 12:03:51', b'0', NULL);
INSERT INTO `order_items` VALUES (230, 170, 13, '2026-04-28 12:03:37', 1, 30.40, 30.40, NULL, NULL, 17, '粤菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349019156', '2026-04-28 12:03:39', '2026-04-28 12:03:37', '2026-04-28 12:03:51', b'0', NULL);
INSERT INTO `order_items` VALUES (231, 171, 32, '2026-04-28 12:04:29', 1, 41.60, 41.60, NULL, NULL, 18, '苏菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349071073', '2026-04-28 12:04:31', '2026-04-28 12:04:29', '2026-04-28 12:05:26', b'0', NULL);
INSERT INTO `order_items` VALUES (232, 171, 34, '2026-04-28 12:04:29', 1, 14.40, 14.40, NULL, NULL, 7, '甜品窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349071073', '2026-04-28 12:04:31', '2026-04-28 12:04:29', '2026-04-28 12:05:26', b'0', NULL);
INSERT INTO `order_items` VALUES (233, 172, 29, '2026-04-28 12:04:46', 1, 36.00, 36.00, NULL, NULL, 14, '湘菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349088149', '2026-04-28 12:04:48', '2026-04-28 12:04:46', '2026-04-28 12:05:29', b'0', NULL);
INSERT INTO `order_items` VALUES (234, 172, 30, '2026-04-28 12:04:46', 1, 38.40, 38.40, NULL, NULL, 22, '浙菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349088149', '2026-04-28 12:04:48', '2026-04-28 12:04:46', '2026-04-28 12:05:29', b'0', NULL);
INSERT INTO `order_items` VALUES (235, 173, 1, '2026-04-28 12:10:00', 1, 7.20, 7.20, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (236, 173, 3, '2026-04-28 12:10:00', 1, 6.40, 6.40, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (237, 173, 8, '2026-04-28 12:10:00', 1, 16.00, 16.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (238, 173, 7, '2026-04-28 12:10:00', 1, 8.00, 8.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (239, 173, 11, '2026-04-28 12:10:00', 1, 1.20, 1.20, NULL, NULL, 13, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (240, 173, 10, '2026-04-28 12:10:00', 1, 1.60, 1.60, NULL, NULL, 3, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (241, 173, 21, '2026-04-28 12:10:00', 1, 12.00, 12.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (242, 173, 18, '2026-04-28 12:10:00', 1, 33.60, 33.60, NULL, NULL, 25, '特色菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (243, 173, 29, '2026-04-28 12:10:00', 1, 36.00, 36.00, NULL, NULL, 14, '湘菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (244, 173, 28, '2026-04-28 12:10:00', 1, 25.60, 25.60, NULL, NULL, 5, '湘菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349401822', '2026-04-28 12:10:02', '2026-04-28 12:10:00', '2026-04-28 12:10:09', b'0', NULL);
INSERT INTO `order_items` VALUES (245, 174, 24, '2026-04-28 12:11:12', 1, 54.40, 54.40, NULL, NULL, 27, '苏菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349473942', '2026-04-28 12:11:14', '2026-04-28 12:11:12', '2026-04-28 12:11:21', b'0', NULL);
INSERT INTO `order_items` VALUES (246, 174, 25, '2026-04-28 12:11:12', 1, 46.40, 46.40, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349473942', '2026-04-28 12:11:14', '2026-04-28 12:11:12', '2026-04-28 12:11:21', b'0', NULL);
INSERT INTO `order_items` VALUES (247, 174, 14, '2026-04-28 12:11:12', 1, 12.80, 12.80, NULL, NULL, 26, '粤菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349473942', '2026-04-28 12:11:14', '2026-04-28 12:11:12', '2026-04-28 12:11:21', b'0', NULL);
INSERT INTO `order_items` VALUES (248, 174, 23, '2026-04-28 12:11:12', 1, 8.00, 8.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349473942', '2026-04-28 12:11:14', '2026-04-28 12:11:12', '2026-04-28 12:11:21', b'0', NULL);
INSERT INTO `order_items` VALUES (249, 174, 27, '2026-04-28 12:11:12', 1, 46.40, 46.40, NULL, NULL, 24, '湘菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349473942', '2026-04-28 12:11:14', '2026-04-28 12:11:12', '2026-04-28 12:11:21', b'0', NULL);
INSERT INTO `order_items` VALUES (250, 174, 32, '2026-04-28 12:11:12', 1, 41.60, 41.60, NULL, NULL, 18, '苏菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349473942', '2026-04-28 12:11:14', '2026-04-28 12:11:12', '2026-04-28 12:11:21', b'0', NULL);
INSERT INTO `order_items` VALUES (251, 175, 1, '2026-04-28 12:13:29', 1, 7.20, 7.20, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777349610858', '2026-04-28 12:13:31', '2026-04-28 12:13:29', '2026-04-28 12:13:37', b'0', NULL);
INSERT INTO `order_items` VALUES (252, 176, 30, '2026-04-28 15:55:12', 1, 38.40, 38.40, NULL, NULL, 22, '浙菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777362913909', '2026-04-28 15:55:14', '2026-04-28 15:55:12', '2026-04-28 15:56:35', b'0', NULL);
INSERT INTO `order_items` VALUES (253, 177, 1, '2026-04-28 15:58:02', 1, 7.20, 7.20, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777363095850', '2026-04-28 15:58:16', '2026-04-28 15:58:03', '2026-04-28 15:58:28', b'0', NULL);
INSERT INTO `order_items` VALUES (254, 178, 1, '2026-04-28 16:00:11', 1, 7.20, 7.20, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777363212853', '2026-04-28 16:00:13', '2026-04-28 16:00:11', '2026-04-28 16:00:22', b'0', NULL);
INSERT INTO `order_items` VALUES (255, 179, 34, '2026-04-28 20:54:00', 1, 14.40, 14.40, NULL, NULL, 7, '甜品窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1777380842330', '2026-04-28 20:54:02', '2026-04-28 20:54:01', '2026-04-28 20:54:10', b'0', NULL);
INSERT INTO `order_items` VALUES (261, 185, 3, '2026-05-09 22:16:30', 1, 6.40, 6.40, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:16:30', '2026-05-09 22:16:30', b'0', NULL);
INSERT INTO `order_items` VALUES (262, 185, 4, '2026-05-09 22:16:30', 1, 5.60, 5.60, NULL, NULL, 6, '特色菜窗口', '二楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:16:30', '2026-05-09 22:16:30', b'0', NULL);
INSERT INTO `order_items` VALUES (263, 186, 7, '2026-05-09 22:16:34', 1, 8.00, 8.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:16:34', '2026-05-09 22:16:34', b'0', NULL);
INSERT INTO `order_items` VALUES (264, 186, 6, '2026-05-09 22:16:34', 1, 2.40, 2.40, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:16:34', '2026-05-09 22:16:34', b'0', NULL);
INSERT INTO `order_items` VALUES (265, 187, 14, '2026-05-09 22:17:03', 1, 12.80, 12.80, NULL, NULL, 26, '粤菜窗口', '二楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:17:04', '2026-05-09 22:17:04', b'0', NULL);
INSERT INTO `order_items` VALUES (266, 187, 13, '2026-05-09 22:17:03', 1, 30.40, 30.40, NULL, NULL, 17, '粤菜窗口', '二楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:17:04', '2026-05-09 22:17:04', b'0', NULL);
INSERT INTO `order_items` VALUES (267, 188, 31, '2026-05-09 22:17:10', 1, 54.40, 54.40, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336287586', '2026-05-09 22:18:08', '2026-05-09 22:17:11', '2026-05-09 22:18:44', b'0', NULL);
INSERT INTO `order_items` VALUES (268, 188, 32, '2026-05-09 22:17:10', 1, 41.60, 41.60, NULL, NULL, 18, '苏菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336287586', '2026-05-09 22:18:08', '2026-05-09 22:17:11', '2026-05-09 22:18:44', b'0', NULL);
INSERT INTO `order_items` VALUES (269, 189, 19, '2026-05-09 22:17:19', 1, 38.40, 38.40, NULL, NULL, 10, '鲁菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336249625', '2026-05-09 22:17:30', '2026-05-09 22:17:19', '2026-05-09 22:30:19', b'0', NULL);
INSERT INTO `order_items` VALUES (270, 189, 18, '2026-05-09 22:17:19', 1, 33.60, 33.60, NULL, NULL, 25, '特色菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336249625', '2026-05-09 22:17:30', '2026-05-09 22:17:19', '2026-05-09 22:30:19', b'0', NULL);
INSERT INTO `order_items` VALUES (271, 189, 17, '2026-05-09 22:17:19', 1, 28.00, 28.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336249625', '2026-05-09 22:17:30', '2026-05-09 22:17:19', '2026-05-09 22:30:19', b'0', NULL);
INSERT INTO `order_items` VALUES (272, 189, 22, '2026-05-09 22:17:19', 1, 9.60, 9.60, NULL, NULL, 9, '面食窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336249625', '2026-05-09 22:17:30', '2026-05-09 22:17:19', '2026-05-09 22:30:19', b'0', NULL);
INSERT INTO `order_items` VALUES (273, 189, 21, '2026-05-09 22:17:19', 1, 12.00, 12.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336249625', '2026-05-09 22:17:30', '2026-05-09 22:17:19', '2026-05-09 22:30:19', b'0', NULL);
INSERT INTO `order_items` VALUES (274, 190, 10, '2026-05-09 22:17:25', 1, 1.60, 1.60, NULL, NULL, 3, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336247577', '2026-05-09 22:17:28', '2026-05-09 22:17:26', '2026-05-09 22:30:02', b'0', NULL);
INSERT INTO `order_items` VALUES (275, 190, 11, '2026-05-09 22:17:25', 1, 1.20, 1.20, NULL, NULL, 13, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336247577', '2026-05-09 22:17:28', '2026-05-09 22:17:26', '2026-05-09 22:30:02', b'0', NULL);
INSERT INTO `order_items` VALUES (276, 191, 16, '2026-05-09 22:19:57', 1, 25.60, 25.60, NULL, NULL, 8, '粤菜窗口', '三楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:19:57', '2026-05-09 22:19:57', b'0', NULL);
INSERT INTO `order_items` VALUES (277, 191, 32, '2026-05-09 22:19:57', 1, 41.60, 41.60, NULL, NULL, 18, '苏菜窗口', '二楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:19:57', '2026-05-09 22:19:57', b'0', NULL);
INSERT INTO `order_items` VALUES (278, 191, 26, '2026-05-09 22:19:57', 1, 17.60, 17.60, NULL, NULL, 16, '盖浇饭窗口', '三楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:19:57', '2026-05-09 22:19:57', b'0', NULL);
INSERT INTO `order_items` VALUES (279, 191, 13, '2026-05-09 22:19:57', 1, 30.40, 30.40, NULL, NULL, 17, '粤菜窗口', '二楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:19:57', '2026-05-09 22:19:57', b'0', NULL);
INSERT INTO `order_items` VALUES (280, 191, 17, '2026-05-09 22:19:57', 1, 28.00, 28.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:19:57', '2026-05-09 22:19:57', b'0', NULL);
INSERT INTO `order_items` VALUES (281, 191, 6, '2026-05-09 22:19:57', 1, 2.40, 2.40, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:19:57', '2026-05-09 22:19:57', b'0', NULL);
INSERT INTO `order_items` VALUES (282, 191, 5, '2026-05-09 22:19:57', 1, 4.00, 4.00, NULL, NULL, 15, '特色菜窗口', '二楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:19:57', '2026-05-09 22:19:57', b'0', NULL);
INSERT INTO `order_items` VALUES (283, 192, 8, '2026-05-09 22:20:06', 1, 16.00, 16.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336407640', '2026-05-09 22:20:08', '2026-05-09 22:20:06', '2026-05-09 22:30:03', b'0', NULL);
INSERT INTO `order_items` VALUES (284, 192, 9, '2026-05-09 22:20:06', 1, 12.80, 12.80, NULL, NULL, 23, '清真窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336407640', '2026-05-09 22:20:08', '2026-05-09 22:20:06', '2026-05-09 22:30:03', b'0', NULL);
INSERT INTO `order_items` VALUES (285, 193, 4, '2026-05-09 22:20:11', 1, 5.60, 5.60, NULL, NULL, 6, '特色菜窗口', '二楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:20:11', '2026-05-09 22:20:11', b'0', NULL);
INSERT INTO `order_items` VALUES (286, 194, 25, '2026-05-09 22:20:17', 1, 46.40, 46.40, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:20:17', '2026-05-09 22:20:17', b'0', NULL);
INSERT INTO `order_items` VALUES (287, 194, 26, '2026-05-09 22:20:17', 1, 17.60, 17.60, NULL, NULL, 16, '盖浇饭窗口', '三楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:20:17', '2026-05-09 22:20:17', b'0', NULL);
INSERT INTO `order_items` VALUES (288, 195, 24, '2026-05-09 22:20:24', 1, 54.40, 54.40, NULL, NULL, 27, '苏菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476801381', '2026-05-11 13:20:01', '2026-05-09 22:20:24', '2026-05-12 11:37:37', b'0', NULL);
INSERT INTO `order_items` VALUES (289, 195, 23, '2026-05-09 22:20:24', 1, 8.00, 8.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476801381', '2026-05-11 13:20:01', '2026-05-09 22:20:24', '2026-05-12 11:37:37', b'0', NULL);
INSERT INTO `order_items` VALUES (290, 196, 34, '2026-05-09 22:20:31', 1, 14.40, 14.40, NULL, NULL, 7, '甜品窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336439752', '2026-05-09 22:20:40', '2026-05-09 22:20:31', '2026-05-09 22:26:12', b'0', NULL);
INSERT INTO `order_items` VALUES (291, 196, 30, '2026-05-09 22:20:31', 1, 38.40, 38.40, NULL, NULL, 22, '浙菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336439752', '2026-05-09 22:20:40', '2026-05-09 22:20:31', '2026-05-09 22:26:12', b'0', NULL);
INSERT INTO `order_items` VALUES (292, 197, 29, '2026-05-09 22:20:37', 1, 36.00, 36.00, NULL, NULL, 14, '湘菜窗口', '一楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:20:38', '2026-05-09 22:20:38', b'0', NULL);
INSERT INTO `order_items` VALUES (293, 197, 28, '2026-05-09 22:20:37', 1, 25.60, 25.60, NULL, NULL, 5, '湘菜窗口', '一楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:20:38', '2026-05-09 22:20:38', b'0', NULL);
INSERT INTO `order_items` VALUES (294, 197, 27, '2026-05-09 22:20:37', 1, 46.40, 46.40, NULL, NULL, 24, '湘菜窗口', '三楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:20:38', '2026-05-09 22:20:38', b'0', NULL);
INSERT INTO `order_items` VALUES (295, 198, 2, '2026-05-09 22:20:45', 1, 7.60, 7.60, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:20:46', '2026-05-09 22:20:46', b'0', NULL);
INSERT INTO `order_items` VALUES (296, 199, 4, '2026-05-09 22:21:33', 1, 5.60, 5.60, NULL, NULL, 6, '特色菜窗口', '二楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:21:33', '2026-05-09 22:21:33', b'0', NULL);
INSERT INTO `order_items` VALUES (297, 199, 3, '2026-05-09 22:21:33', 1, 6.40, 6.40, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:21:33', '2026-05-09 22:21:33', b'0', NULL);
INSERT INTO `order_items` VALUES (298, 199, 10, '2026-05-09 22:21:33', 1, 1.60, 1.60, NULL, NULL, 3, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:21:33', '2026-05-09 22:21:33', b'0', NULL);
INSERT INTO `order_items` VALUES (299, 199, 11, '2026-05-09 22:21:33', 1, 1.20, 1.20, NULL, NULL, 13, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:21:33', '2026-05-09 22:21:33', b'0', NULL);
INSERT INTO `order_items` VALUES (300, 200, 24, '2026-05-09 22:21:39', 1, 54.40, 54.40, NULL, NULL, 27, '苏菜窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336727823', '2026-05-09 22:25:28', '2026-05-09 22:21:40', '2026-05-09 22:26:08', b'0', NULL);
INSERT INTO `order_items` VALUES (301, 200, 23, '2026-05-09 22:21:39', 1, 8.00, 8.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336727823', '2026-05-09 22:25:28', '2026-05-09 22:21:40', '2026-05-09 22:26:08', b'0', NULL);
INSERT INTO `order_items` VALUES (302, 200, 22, '2026-05-09 22:21:39', 1, 9.60, 9.60, NULL, NULL, 9, '面食窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336727823', '2026-05-09 22:25:28', '2026-05-09 22:21:40', '2026-05-09 22:26:08', b'0', NULL);
INSERT INTO `order_items` VALUES (303, 201, 7, '2026-05-09 22:26:54', 1, 8.00, 8.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336816640', '2026-05-09 22:26:57', '2026-05-09 22:26:54', '2026-05-11 13:20:45', b'0', NULL);
INSERT INTO `order_items` VALUES (304, 201, 6, '2026-05-09 22:26:54', 1, 2.40, 2.40, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336816640', '2026-05-09 22:26:57', '2026-05-09 22:26:54', '2026-05-11 13:20:45', b'0', NULL);
INSERT INTO `order_items` VALUES (305, 201, 8, '2026-05-09 22:26:54', 1, 16.00, 16.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336816640', '2026-05-09 22:26:57', '2026-05-09 22:26:54', '2026-05-11 13:20:45', b'0', NULL);
INSERT INTO `order_items` VALUES (306, 202, 11, '2026-05-09 22:27:00', 1, 1.20, 1.20, NULL, NULL, 13, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:27:01', '2026-05-09 22:27:01', b'0', NULL);
INSERT INTO `order_items` VALUES (307, 203, 12, '2026-05-09 22:27:04', 2, 22.40, 44.80, NULL, NULL, 2, '川菜窗口', '二楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:27:04', '2026-05-09 22:27:04', b'0', NULL);
INSERT INTO `order_items` VALUES (308, 204, 31, '2026-05-09 22:27:09', 1, 54.40, 54.40, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778337046014', '2026-05-09 22:30:46', '2026-05-09 22:27:10', '2026-05-09 22:30:46', b'0', NULL);
INSERT INTO `order_items` VALUES (309, 204, 27, '2026-05-09 22:27:09', 3, 46.40, 139.20, NULL, NULL, 24, '湘菜窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778337046014', '2026-05-09 22:30:46', '2026-05-09 22:27:10', '2026-05-09 22:30:46', b'0', NULL);
INSERT INTO `order_items` VALUES (310, 205, 29, '2026-05-09 22:27:15', 1, 36.00, 36.00, NULL, NULL, 14, '湘菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778337044584', '2026-05-09 22:30:45', '2026-05-09 22:27:16', '2026-05-09 22:30:45', b'0', NULL);
INSERT INTO `order_items` VALUES (311, 205, 30, '2026-05-09 22:27:15', 1, 38.40, 38.40, NULL, NULL, 22, '浙菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778337044584', '2026-05-09 22:30:45', '2026-05-09 22:27:16', '2026-05-09 22:30:45', b'0', NULL);
INSERT INTO `order_items` VALUES (312, 205, 28, '2026-05-09 22:27:15', 1, 25.60, 25.60, NULL, NULL, 5, '湘菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778337044584', '2026-05-09 22:30:45', '2026-05-09 22:27:16', '2026-05-09 22:30:45', b'0', NULL);
INSERT INTO `order_items` VALUES (313, 206, 22, '2026-05-09 22:27:22', 1, 9.60, 9.60, NULL, NULL, 9, '面食窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336847944', '2026-05-09 22:27:28', '2026-05-09 22:27:22', '2026-05-12 11:37:50', b'0', NULL);
INSERT INTO `order_items` VALUES (314, 206, 21, '2026-05-09 22:27:22', 1, 12.00, 12.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336847944', '2026-05-09 22:27:28', '2026-05-09 22:27:22', '2026-05-12 11:37:50', b'0', NULL);
INSERT INTO `order_items` VALUES (315, 206, 25, '2026-05-09 22:27:22', 1, 46.40, 46.40, NULL, NULL, 6, '特色菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336847944', '2026-05-09 22:27:28', '2026-05-09 22:27:22', '2026-05-12 11:37:50', b'0', NULL);
INSERT INTO `order_items` VALUES (316, 207, 10, '2026-05-09 22:27:32', 3, 1.60, 4.80, NULL, NULL, 3, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778337042684', '2026-05-09 22:30:43', '2026-05-09 22:27:33', '2026-05-09 22:30:43', b'0', NULL);
INSERT INTO `order_items` VALUES (317, 208, 6, '2026-05-09 22:27:44', 4, 2.40, 9.60, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:27:44', '2026-05-09 22:27:44', b'0', NULL);
INSERT INTO `order_items` VALUES (318, 209, 3, '2026-05-09 22:27:48', 2, 6.40, 12.80, NULL, NULL, 20, '川菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336870155', '2026-05-09 22:27:50', '2026-05-09 22:27:48', '2026-05-09 22:27:50', b'0', NULL);
INSERT INTO `order_items` VALUES (319, 209, 2, '2026-05-09 22:27:48', 1, 7.60, 7.60, NULL, NULL, 12, '川菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778336870155', '2026-05-09 22:27:50', '2026-05-09 22:27:48', '2026-05-09 22:27:50', b'0', NULL);
INSERT INTO `order_items` VALUES (320, 210, 34, '2026-05-09 22:27:56', 1, 14.40, 14.40, NULL, NULL, 7, '甜品窗口', '三楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:27:57', '2026-05-09 22:27:57', b'0', NULL);
INSERT INTO `order_items` VALUES (321, 210, 21, '2026-05-09 22:27:56', 2, 12.00, 24.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:27:57', '2026-05-09 22:27:57', b'0', NULL);
INSERT INTO `order_items` VALUES (322, 211, 31, '2026-05-09 22:28:10', 1, 54.40, 54.40, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:28:10', '2026-05-09 22:28:10', b'0', NULL);
INSERT INTO `order_items` VALUES (323, 211, 18, '2026-05-09 22:28:10', 1, 33.60, 33.60, NULL, NULL, 25, '特色菜窗口', '三楼南侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-09 22:28:10', '2026-05-09 22:28:10', b'0', NULL);
INSERT INTO `order_items` VALUES (324, 212, 9, '2026-05-10 16:43:11', 2, 12.80, 25.60, NULL, NULL, 23, '清真窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778402596378', '2026-05-10 16:43:16', '2026-05-10 16:43:12', '2026-05-10 16:43:16', b'0', NULL);
INSERT INTO `order_items` VALUES (325, 213, 13, '2026-05-11 13:18:03', 1, 30.40, 30.40, NULL, NULL, 17, '粤菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'ALIPAY', 'TX1778476686906', '2026-05-11 13:18:07', '2026-05-11 13:18:04', '2026-05-11 13:18:07', b'0', NULL);
INSERT INTO `order_items` VALUES (326, 213, 16, '2026-05-11 13:18:03', 1, 25.60, 25.60, NULL, NULL, 8, '粤菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'ALIPAY', 'TX1778476686906', '2026-05-11 13:18:07', '2026-05-11 13:18:04', '2026-05-11 13:18:07', b'0', NULL);
INSERT INTO `order_items` VALUES (327, 214, 1, '2026-05-11 13:18:51', 1, 7.68, 7.68, NULL, NULL, 1, '上海菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476732705', '2026-05-11 13:18:53', '2026-05-11 13:18:51', '2026-05-11 13:20:51', b'0', NULL);
INSERT INTO `order_items` VALUES (328, 214, 21, '2026-05-11 13:18:51', 1, 12.00, 12.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476732705', '2026-05-11 13:18:53', '2026-05-11 13:18:51', '2026-05-11 13:20:51', b'0', NULL);
INSERT INTO `order_items` VALUES (329, 215, 8, '2026-05-11 13:19:09', 1, 16.00, 16.00, NULL, NULL, 15, '特色菜窗口', '三楼西侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-11 13:19:10', '2026-05-11 13:19:10', b'0', NULL);
INSERT INTO `order_items` VALUES (330, 215, 34, '2026-05-11 13:19:09', 1, 14.40, 14.40, NULL, NULL, 7, '甜品窗口', '三楼东侧', 'IMMEDIATE', NULL, NULL, NULL, NULL, '2026-05-11 13:19:10', '2026-05-11 13:19:10', b'0', NULL);
INSERT INTO `order_items` VALUES (331, 216, 22, '2026-05-11 13:19:36', 1, 9.60, 9.60, NULL, NULL, 9, '面食窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476779591', '2026-05-11 13:19:40', '2026-05-11 13:19:37', '2026-05-11 13:20:38', b'0', NULL);
INSERT INTO `order_items` VALUES (332, 216, 28, '2026-05-11 13:19:36', 1, 25.60, 25.60, NULL, NULL, 5, '湘菜窗口', '一楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476779591', '2026-05-11 13:19:40', '2026-05-11 13:19:37', '2026-05-11 13:20:38', b'0', NULL);
INSERT INTO `order_items` VALUES (333, 217, 6, '2026-05-11 13:19:56', 1, 2.40, 2.40, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476798588', '2026-05-11 13:19:59', '2026-05-11 13:19:57', '2026-05-11 13:20:41', b'0', NULL);
INSERT INTO `order_items` VALUES (334, 217, 5, '2026-05-11 13:19:56', 1, 4.00, 4.00, NULL, NULL, 15, '特色菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476798588', '2026-05-11 13:19:59', '2026-05-11 13:19:57', '2026-05-11 13:20:41', b'0', NULL);
INSERT INTO `order_items` VALUES (335, 217, 9, '2026-05-11 13:19:56', 1, 12.80, 12.80, NULL, NULL, 23, '清真窗口', '三楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778476798588', '2026-05-11 13:19:59', '2026-05-11 13:19:57', '2026-05-11 13:20:41', b'0', NULL);
INSERT INTO `order_items` VALUES (337, 219, 22, '2026-05-12 00:09:18', 1, 9.60, 9.60, NULL, NULL, 9, '面食窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778515759598', '2026-05-12 00:09:20', '2026-05-12 00:09:18', '2026-05-12 00:09:26', b'0', NULL);
INSERT INTO `order_items` VALUES (338, 220, 6, '2026-05-12 08:47:43', 1, 2.40, 2.40, NULL, NULL, 21, '汤品窗口', '二楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546875871', '2026-05-12 08:47:56', '2026-05-12 08:47:43', '2026-05-12 08:48:49', b'0', NULL);
INSERT INTO `order_items` VALUES (339, 220, 7, '2026-05-12 08:47:43', 1, 8.00, 8.00, NULL, NULL, 2, '川菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546875871', '2026-05-12 08:47:56', '2026-05-12 08:47:43', '2026-05-12 08:48:49', b'0', NULL);
INSERT INTO `order_items` VALUES (340, 221, 23, '2026-05-12 08:47:52', 1, 8.00, 8.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546874167', '2026-05-12 08:47:54', '2026-05-12 08:47:52', '2026-05-12 08:48:49', b'0', NULL);
INSERT INTO `order_items` VALUES (341, 221, 11, '2026-05-12 08:47:52', 1, 1.20, 1.20, NULL, NULL, 13, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546874167', '2026-05-12 08:47:54', '2026-05-12 08:47:52', '2026-05-12 08:48:49', b'0', NULL);
INSERT INTO `order_items` VALUES (342, 222, 21, '2026-05-12 08:48:00', 1, 12.00, 12.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546881730', '2026-05-12 08:48:02', '2026-05-12 08:48:00', '2026-05-12 08:49:05', b'0', NULL);
INSERT INTO `order_items` VALUES (343, 222, 31, '2026-05-12 08:48:00', 1, 54.40, 54.40, NULL, NULL, 4, '浙菜窗口', '二楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546881730', '2026-05-12 08:48:02', '2026-05-12 08:48:00', '2026-05-12 08:49:05', b'0', NULL);
INSERT INTO `order_items` VALUES (344, 223, 10, '2026-05-12 08:48:22', 1, 1.60, 1.60, NULL, NULL, 3, '早餐窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546915576', '2026-05-12 08:48:36', '2026-05-12 08:48:23', '2026-05-12 08:49:04', b'0', NULL);
INSERT INTO `order_items` VALUES (345, 223, 23, '2026-05-12 08:48:22', 1, 8.00, 8.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546915576', '2026-05-12 08:48:36', '2026-05-12 08:48:23', '2026-05-12 08:49:04', b'0', NULL);
INSERT INTO `order_items` VALUES (346, 223, 21, '2026-05-12 08:48:22', 1, 12.00, 12.00, NULL, NULL, 25, '特色菜窗口', '一楼南侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546915576', '2026-05-12 08:48:36', '2026-05-12 08:48:23', '2026-05-12 08:49:04', b'0', NULL);
INSERT INTO `order_items` VALUES (347, 224, 23, '2026-05-12 08:48:31', 1, 8.00, 8.00, NULL, NULL, 11, '上海菜窗口', '二楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546913428', '2026-05-12 08:48:33', '2026-05-12 08:48:31', '2026-05-12 08:49:03', b'0', NULL);
INSERT INTO `order_items` VALUES (348, 224, 16, '2026-05-12 08:48:31', 1, 25.60, 25.60, NULL, NULL, 8, '粤菜窗口', '三楼东侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778546913428', '2026-05-12 08:48:33', '2026-05-12 08:48:31', '2026-05-12 08:49:03', b'0', NULL);
INSERT INTO `order_items` VALUES (349, 225, 29, '2026-05-12 08:50:00', 46, 36.00, 1656.00, NULL, NULL, 14, '湘菜窗口', '一楼西侧', 'IMMEDIATE', NULL, 'WECHAT', 'TX1778547001926', '2026-05-12 08:50:02', '2026-05-12 08:50:01', '2026-05-12 08:50:26', b'0', NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 137 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_status_history
-- ----------------------------
INSERT INTO `order_status_history` VALUES (4, '2026-01-27 14:57:14.600654', 'PENDING', '支付成功，交易号: TX1769497034556', 'PAID', 19);
INSERT INTO `order_status_history` VALUES (24, '2026-02-06 22:23:14.215744', 'PENDING', '支付成功，交易号: TX1770387794189', 'PAID', 69);
INSERT INTO `order_status_history` VALUES (25, '2026-02-06 22:23:43.456122', 'PENDING', '支付成功，交易号: TX1770387823433', 'PAID', 70);
INSERT INTO `order_status_history` VALUES (30, '2026-02-07 23:24:10.498778', 'PENDING', '支付成功，交易号: TX1770477850469', 'PAID', 75);
INSERT INTO `order_status_history` VALUES (46, '2026-02-11 20:30:13.728144', 'PENDING', '支付成功，交易号: TX1770813013695', 'PAID', 94);
INSERT INTO `order_status_history` VALUES (49, '2026-02-12 16:10:57.126612', 'PENDING', '支付成功，交易号: TX1770883857106', 'PAID', 101);
INSERT INTO `order_status_history` VALUES (56, '2026-02-21 20:14:40.102520', 'PENDING', '支付成功，交易号: TX1771676080082', 'PAID', 112);
INSERT INTO `order_status_history` VALUES (58, '2026-03-05 10:19:12.264080', 'PENDING', '支付成功，交易号: TX1772677152236', 'PAID', 113);
INSERT INTO `order_status_history` VALUES (63, '2026-03-23 10:55:49.139658', 'PENDING', '支付成功，交易号: TX1774234548810', 'PAID', 114);
INSERT INTO `order_status_history` VALUES (64, '2026-03-23 11:44:13.641575', 'PENDING', '支付成功，交易号: TX1774237453290', 'PAID', 119);
INSERT INTO `order_status_history` VALUES (65, '2026-03-23 11:51:09.637903', 'PENDING', '支付成功，交易号: TX1774237869568', 'PAID', 120);
INSERT INTO `order_status_history` VALUES (66, '2026-03-25 21:22:48.554448', 'PENDING', '支付成功，交易号: TX1774444968525', 'PAID', 121);
INSERT INTO `order_status_history` VALUES (69, '2026-03-25 21:26:28.761174', 'PENDING', '支付成功，交易号: TX1774445188741', 'PAID', 124);
INSERT INTO `order_status_history` VALUES (72, '2026-03-28 19:58:28.016072', 'PENDING', '支付成功，交易号: TX1774699107992', 'PAID', 128);
INSERT INTO `order_status_history` VALUES (75, '2026-04-04 16:44:44.823646', 'PENDING', '支付成功，交易号: TX1775292284765', 'PAID', 131);
INSERT INTO `order_status_history` VALUES (76, '2026-04-04 16:45:56.116194', 'PENDING', '支付成功，交易号: TX1775292356074', 'PAID', 132);
INSERT INTO `order_status_history` VALUES (83, '2026-04-27 14:45:05.457800', 'PENDING', '支付成功，交易号: TX1777272305431', 'PAID', 139);
INSERT INTO `order_status_history` VALUES (88, '2026-04-27 16:44:02.925488', 'PENDING', '支付成功，交易号: TX1777279442884', 'PAID', 152);
INSERT INTO `order_status_history` VALUES (89, '2026-04-27 16:45:36.922484', 'PENDING', '支付成功，交易号: TX1777279536894', 'PAID', 153);
INSERT INTO `order_status_history` VALUES (91, '2026-04-28 11:18:14.332013', 'PENDING', '支付成功，交易号: TX1777346294293', 'PAID', 162);
INSERT INTO `order_status_history` VALUES (92, '2026-04-28 11:41:04.765442', 'PENDING', '支付成功，交易号: TX1777347664736', 'PAID', 163);
INSERT INTO `order_status_history` VALUES (93, '2026-04-28 11:56:53.636370', 'PENDING', '支付成功，交易号: TX1777348613615', 'PAID', 164);
INSERT INTO `order_status_history` VALUES (94, '2026-04-28 11:58:13.418149', 'PENDING', '支付成功，交易号: TX1777348693392', 'PAID', 165);
INSERT INTO `order_status_history` VALUES (95, '2026-04-28 11:59:27.268153', 'PENDING', '支付成功，交易号: TX1777348767246', 'PAID', 168);
INSERT INTO `order_status_history` VALUES (96, '2026-04-28 11:59:58.926135', 'PENDING', '支付成功，交易号: TX1777348798907', 'PAID', 167);
INSERT INTO `order_status_history` VALUES (97, '2026-04-28 12:00:00.647821', 'PENDING', '支付成功，交易号: TX1777348800624', 'PAID', 166);
INSERT INTO `order_status_history` VALUES (98, '2026-04-28 12:02:20.572460', 'PENDING', '支付成功，交易号: TX1777348940552', 'PAID', 169);
INSERT INTO `order_status_history` VALUES (99, '2026-04-28 12:03:39.175729', 'PENDING', '支付成功，交易号: TX1777349019156', 'PAID', 170);
INSERT INTO `order_status_history` VALUES (100, '2026-04-28 12:04:31.100527', 'PENDING', '支付成功，交易号: TX1777349071073', 'PAID', 171);
INSERT INTO `order_status_history` VALUES (101, '2026-04-28 12:04:48.173062', 'PENDING', '支付成功，交易号: TX1777349088149', 'PAID', 172);
INSERT INTO `order_status_history` VALUES (102, '2026-04-28 12:10:01.850991', 'PENDING', '支付成功，交易号: TX1777349401822', 'PAID', 173);
INSERT INTO `order_status_history` VALUES (103, '2026-04-28 12:11:13.964630', 'PENDING', '支付成功，交易号: TX1777349473942', 'PAID', 174);
INSERT INTO `order_status_history` VALUES (104, '2026-04-28 12:13:30.876875', 'PENDING', '支付成功，交易号: TX1777349610858', 'PAID', 175);
INSERT INTO `order_status_history` VALUES (105, '2026-04-28 15:55:13.942204', 'PENDING', '支付成功，交易号: TX1777362913909', 'PAID', 176);
INSERT INTO `order_status_history` VALUES (106, '2026-04-28 15:58:15.879670', 'PENDING', '支付成功，交易号: TX1777363095850', 'PAID', 177);
INSERT INTO `order_status_history` VALUES (107, '2026-04-28 16:00:12.874541', 'PENDING', '支付成功，交易号: TX1777363212853', 'PAID', 178);
INSERT INTO `order_status_history` VALUES (108, '2026-04-28 20:54:02.365949', 'PENDING', '支付成功，交易号: TX1777380842330', 'PAID', 179);
INSERT INTO `order_status_history` VALUES (111, '2026-05-09 22:17:27.610029', 'PENDING', '支付成功，交易号: TX1778336247577', 'PAID', 190);
INSERT INTO `order_status_history` VALUES (112, '2026-05-09 22:17:29.659649', 'PENDING', '支付成功，交易号: TX1778336249625', 'PAID', 189);
INSERT INTO `order_status_history` VALUES (113, '2026-05-09 22:18:07.614397', 'PENDING', '支付成功，交易号: TX1778336287586', 'PAID', 188);
INSERT INTO `order_status_history` VALUES (114, '2026-05-09 22:20:07.662108', 'PENDING', '支付成功，交易号: TX1778336407640', 'PAID', 192);
INSERT INTO `order_status_history` VALUES (115, '2026-05-09 22:20:39.777274', 'PENDING', '支付成功，交易号: TX1778336439752', 'PAID', 196);
INSERT INTO `order_status_history` VALUES (116, '2026-05-09 22:25:27.844659', 'PENDING', '支付成功，交易号: TX1778336727823', 'PAID', 200);
INSERT INTO `order_status_history` VALUES (117, '2026-05-09 22:26:56.665083', 'PENDING', '支付成功，交易号: TX1778336816640', 'PAID', 201);
INSERT INTO `order_status_history` VALUES (118, '2026-05-09 22:27:27.963056', 'PENDING', '支付成功，交易号: TX1778336847944', 'PAID', 206);
INSERT INTO `order_status_history` VALUES (119, '2026-05-09 22:27:50.180562', 'PENDING', '支付成功，交易号: TX1778336870155', 'PAID', 209);
INSERT INTO `order_status_history` VALUES (120, '2026-05-09 22:30:42.706872', 'PENDING', '支付成功，交易号: TX1778337042684', 'PAID', 207);
INSERT INTO `order_status_history` VALUES (121, '2026-05-09 22:30:44.606838', 'PENDING', '支付成功，交易号: TX1778337044584', 'PAID', 205);
INSERT INTO `order_status_history` VALUES (122, '2026-05-09 22:30:46.034798', 'PENDING', '支付成功，交易号: TX1778337046014', 'PAID', 204);
INSERT INTO `order_status_history` VALUES (123, '2026-05-10 16:43:16.412739', 'PENDING', '支付成功，交易号: TX1778402596378', 'PAID', 212);
INSERT INTO `order_status_history` VALUES (124, '2026-05-11 13:18:06.944021', 'PENDING', '支付成功，交易号: TX1778476686906', 'PAID', 213);
INSERT INTO `order_status_history` VALUES (125, '2026-05-11 13:18:52.734684', 'PENDING', '支付成功，交易号: TX1778476732705', 'PAID', 214);
INSERT INTO `order_status_history` VALUES (126, '2026-05-11 13:19:39.633547', 'PENDING', '支付成功，交易号: TX1778476779591', 'PAID', 216);
INSERT INTO `order_status_history` VALUES (127, '2026-05-11 13:19:58.616432', 'PENDING', '支付成功，交易号: TX1778476798588', 'PAID', 217);
INSERT INTO `order_status_history` VALUES (128, '2026-05-11 13:20:01.406386', 'PENDING', '支付成功，交易号: TX1778476801381', 'PAID', 195);
INSERT INTO `order_status_history` VALUES (130, '2026-05-12 00:09:19.619370', 'PENDING', '支付成功，交易号: TX1778515759598', 'PAID', 219);
INSERT INTO `order_status_history` VALUES (131, '2026-05-12 08:47:54.199041', 'PENDING', '支付成功，交易号: TX1778546874167', 'PAID', 221);
INSERT INTO `order_status_history` VALUES (132, '2026-05-12 08:47:55.904722', 'PENDING', '支付成功，交易号: TX1778546875871', 'PAID', 220);
INSERT INTO `order_status_history` VALUES (133, '2026-05-12 08:48:01.756712', 'PENDING', '支付成功，交易号: TX1778546881730', 'PAID', 222);
INSERT INTO `order_status_history` VALUES (134, '2026-05-12 08:48:33.455744', 'PENDING', '支付成功，交易号: TX1778546913428', 'PAID', 224);
INSERT INTO `order_status_history` VALUES (135, '2026-05-12 08:48:35.608856', 'PENDING', '支付成功，交易号: TX1778546915576', 'PAID', 223);
INSERT INTO `order_status_history` VALUES (136, '2026-05-12 08:50:01.944445', 'PENDING', '支付成功，交易号: TX1778547001926', 'PAID', 225);

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
) ENGINE = InnoDB AUTO_INCREMENT = 226 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (19, 1, 'ORD176889886302018', 'COMPLETED', 126.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (20, 3, 'ORD176889886302919', 'COMPLETED', 102.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (21, 4, 'ORD176889886304220', 'COMPLETED', 234.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (27, 4, 'ORD176889886312526', 'COMPLETED', 46.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (29, 3, 'ORD176889886314528', 'COMPLETED', 212.00, NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (69, 1, 'ORD1770387792782', 'COMPLETED', 25.20, 25.20, 25.20, 0.00, NULL);
INSERT INTO `orders` VALUES (70, 1, 'ORD1770387821949', 'COMPLETED', 294.00, 294.00, 294.00, 0.00, NULL);
INSERT INTO `orders` VALUES (75, 1, 'ORD1770477849290', 'COMPLETED', 2030.00, 2030.00, 2030.00, 0.00, NULL);
INSERT INTO `orders` VALUES (94, 1, 'ORD1770813010947', 'COMPLETED', 7.00, 7.00, 7.00, 0.00, NULL);
INSERT INTO `orders` VALUES (101, 1, 'ORD1770883855561', 'COMPLETED', 8.00, 8.00, 8.00, 0.00, NULL);
INSERT INTO `orders` VALUES (112, 1, 'ORD1771676077714', 'COMPLETED', 8.75, 8.75, 8.75, 0.00, NULL);
INSERT INTO `orders` VALUES (113, 1, 'ORD1772677145008', 'PREPARING', 8.00, 8.00, 8.00, 0.00, NULL);
INSERT INTO `orders` VALUES (114, 3, 'ORD1773203087685', 'COMPLETED', 10.00, 10.00, 10.00, 0.00, NULL);
INSERT INTO `orders` VALUES (119, 1, 'ORD1774237451243', 'COMPLETED', 20.00, 20.00, 20.00, 0.00, NULL);
INSERT INTO `orders` VALUES (120, 1, 'ORD1774237867698', 'COMPLETED', 20.00, 20.00, 20.00, 0.00, NULL);
INSERT INTO `orders` VALUES (121, 1, 'ORD1774444966693', 'COMPLETED', 720.00, 720.00, 720.00, 0.00, NULL);
INSERT INTO `orders` VALUES (124, 1, 'ORD1774445187160', 'COMPLETED', 2898.00, 2898.00, 2898.00, 0.00, NULL);
INSERT INTO `orders` VALUES (128, 1, 'ORD1774699106216', 'COMPLETED', 400.00, 400.00, 400.00, 0.00, NULL);
INSERT INTO `orders` VALUES (131, 3, 'ORD1775292282808', 'COMPLETED', 8.00, 8.00, 8.00, 0.00, NULL);
INSERT INTO `orders` VALUES (132, 1, 'ORD1775292353307', 'COMPLETED', 9.60, 9.60, 9.60, 0.00, NULL);
INSERT INTO `orders` VALUES (139, 8, 'ORD1777272304050', 'COMPLETED', 1120.00, 1120.00, 1120.00, 0.00, NULL);
INSERT INTO `orders` VALUES (152, 1, 'ORD1777279441063', 'COMPLETED', 9.60, 9.60, 9.60, 0.00, NULL);
INSERT INTO `orders` VALUES (153, 1, 'ORD1777279535271', 'COMPLETED', 46.40, 46.40, 46.40, 0.00, NULL);
INSERT INTO `orders` VALUES (162, 1, 'ORD1777346290783', 'COMPLETED', 18.00, 18.00, 18.00, 0.00, NULL);
INSERT INTO `orders` VALUES (163, 1, 'ORD1777347662641', 'COMPLETED', 54.40, 54.40, 54.40, 0.00, NULL);
INSERT INTO `orders` VALUES (164, 1, 'ORD1777348612244', 'COMPLETED', 12.80, 12.80, 12.80, 0.00, NULL);
INSERT INTO `orders` VALUES (165, 1, 'ORD1777348690203', 'COMPLETED', 7.60, 7.60, 7.60, 0.00, NULL);
INSERT INTO `orders` VALUES (166, 5, 'ORD1777348734179', 'COMPLETED', 22.40, 22.40, 22.40, 0.00, NULL);
INSERT INTO `orders` VALUES (167, 5, 'ORD1777348742411', 'COMPLETED', 17.60, 17.60, 17.60, 0.00, NULL);
INSERT INTO `orders` VALUES (168, 5, 'ORD1777348764707', 'COMPLETED', 25.60, 25.60, 25.60, 0.00, NULL);
INSERT INTO `orders` VALUES (169, 9, 'ORD1777348939309', 'COMPLETED', 38.40, 38.40, 38.40, 0.00, NULL);
INSERT INTO `orders` VALUES (170, 9, 'ORD1777349017456', 'COMPLETED', 58.40, 58.40, 58.40, 0.00, NULL);
INSERT INTO `orders` VALUES (171, 8, 'ORD1777349069483', 'COMPLETED', 56.00, 56.00, 56.00, 0.00, NULL);
INSERT INTO `orders` VALUES (172, 8, 'ORD1777349086113', 'COMPLETED', 74.40, 74.40, 74.40, 0.00, NULL);
INSERT INTO `orders` VALUES (173, 1, 'ORD1777349400015', 'COMPLETED', 147.60, 147.60, 147.60, 0.00, NULL);
INSERT INTO `orders` VALUES (174, 1, 'ORD1777349472118', 'COMPLETED', 209.60, 209.60, 209.60, 0.00, NULL);
INSERT INTO `orders` VALUES (175, 1, 'ORD1777349609262', 'COMPLETED', 7.20, 7.20, 7.20, 0.00, NULL);
INSERT INTO `orders` VALUES (176, 1, 'ORD1777362912399', 'COMPLETED', 38.40, 38.40, 38.40, 0.00, NULL);
INSERT INTO `orders` VALUES (177, 1, 'ORD1777363082934', 'COMPLETED', 7.20, 7.20, 7.20, 0.00, NULL);
INSERT INTO `orders` VALUES (178, 1, 'ORD1777363211432', 'COMPLETED', 7.20, 7.20, 7.20, 0.00, NULL);
INSERT INTO `orders` VALUES (179, 1, 'ORD1777380840741', 'COMPLETED', 14.40, 14.40, 14.40, 0.00, NULL);
INSERT INTO `orders` VALUES (185, 5, 'ORD1778336190286', 'CANCELLED', 12.00, 12.00, 12.00, 0.00, NULL);
INSERT INTO `orders` VALUES (186, 5, 'ORD1778336194025', 'CANCELLED', 10.40, 10.40, 10.40, 0.00, NULL);
INSERT INTO `orders` VALUES (187, 5, 'ORD1778336223878', 'CANCELLED', 43.20, 43.20, 43.20, 0.00, NULL);
INSERT INTO `orders` VALUES (188, 5, 'ORD1778336230674', 'COMPLETED', 96.00, 96.00, 96.00, 0.00, NULL);
INSERT INTO `orders` VALUES (189, 5, 'ORD1778336239365', 'READY', 121.60, 121.60, 121.60, 0.00, NULL);
INSERT INTO `orders` VALUES (190, 5, 'ORD1778336245510', 'PREPARING', 2.80, 2.80, 2.80, 0.00, NULL);
INSERT INTO `orders` VALUES (191, 7, 'ORD1778336397294', 'CANCELLED', 149.60, 149.60, 149.60, 0.00, NULL);
INSERT INTO `orders` VALUES (192, 7, 'ORD1778336406258', 'PREPARING', 28.80, 28.80, 28.80, 0.00, NULL);
INSERT INTO `orders` VALUES (193, 7, 'ORD1778336411403', 'CANCELLED', 5.60, 5.60, 5.60, 0.00, NULL);
INSERT INTO `orders` VALUES (194, 7, 'ORD1778336417403', 'CANCELLED', 64.00, 64.00, 64.00, 0.00, NULL);
INSERT INTO `orders` VALUES (195, 7, 'ORD1778336424497', 'PREPARING', 62.40, 62.40, 62.40, 0.00, NULL);
INSERT INTO `orders` VALUES (196, 7, 'ORD1778336431153', 'READY', 52.80, 52.80, 52.80, 0.00, NULL);
INSERT INTO `orders` VALUES (197, 7, 'ORD1778336437542', 'PENDING', 108.00, 108.00, 108.00, 0.00, NULL);
INSERT INTO `orders` VALUES (198, 7, 'ORD1778336445884', 'PENDING', 7.60, 7.60, 7.60, 0.00, NULL);
INSERT INTO `orders` VALUES (199, 9, 'ORD1778336493000', 'PENDING', 14.80, 14.80, 14.80, 0.00, NULL);
INSERT INTO `orders` VALUES (200, 9, 'ORD1778336499511', 'READY', 72.00, 72.00, 72.00, 0.00, NULL);
INSERT INTO `orders` VALUES (201, 10, 'ORD1778336814299', 'COMPLETED', 26.40, 26.40, 26.40, 0.00, NULL);
INSERT INTO `orders` VALUES (202, 10, 'ORD1778336820537', 'PENDING', 1.20, 1.20, 1.20, 0.00, NULL);
INSERT INTO `orders` VALUES (203, 10, 'ORD1778336824346', 'PENDING', 44.80, 44.80, 44.80, 0.00, NULL);
INSERT INTO `orders` VALUES (204, 10, 'ORD1778336829866', 'PAID', 193.60, 193.60, 193.60, 0.00, NULL);
INSERT INTO `orders` VALUES (205, 10, 'ORD1778336835624', 'PAID', 100.00, 100.00, 100.00, 0.00, NULL);
INSERT INTO `orders` VALUES (206, 10, 'ORD1778336842472', 'COMPLETED', 68.00, 68.00, 68.00, 0.00, NULL);
INSERT INTO `orders` VALUES (207, 10, 'ORD1778336852538', 'PAID', 4.80, 4.80, 4.80, 0.00, NULL);
INSERT INTO `orders` VALUES (208, 11, 'ORD1778336864133', 'PENDING', 9.60, 9.60, 9.60, 0.00, NULL);
INSERT INTO `orders` VALUES (209, 11, 'ORD1778336868057', 'PAID', 20.40, 20.40, 20.40, 0.00, NULL);
INSERT INTO `orders` VALUES (210, 11, 'ORD1778336876808', 'PENDING', 38.40, 38.40, 38.40, 0.00, NULL);
INSERT INTO `orders` VALUES (211, 11, 'ORD1778336890289', 'PENDING', 88.00, 88.00, 88.00, 0.00, NULL);
INSERT INTO `orders` VALUES (212, 1, 'ORD1778402591861', 'PAID', 20.60, 20.60, 20.60, 0.00, NULL);
INSERT INTO `orders` VALUES (213, 3, 'ORD1778476683685', 'PAID', 51.00, 51.00, 51.00, 0.00, NULL);
INSERT INTO `orders` VALUES (214, 4, 'ORD1778476731190', 'COMPLETED', 19.68, 19.68, 19.68, 0.00, NULL);
INSERT INTO `orders` VALUES (215, 5, 'ORD1778476749651', 'CANCELLED', 30.40, 30.40, 30.40, 0.00, NULL);
INSERT INTO `orders` VALUES (216, 9, 'ORD1778476776919', 'PREPARING', 35.20, 35.20, 35.20, 0.00, NULL);
INSERT INTO `orders` VALUES (217, 7, 'ORD1778476796769', 'COMPLETED', 19.20, 19.20, 19.20, 0.00, NULL);
INSERT INTO `orders` VALUES (219, 1, 'ORD1778515758294', 'COMPLETED', 9.60, 9.60, 9.60, 0.00, NULL);
INSERT INTO `orders` VALUES (220, 4, 'ORD1778546863432', 'COMPLETED', 10.40, 10.40, 10.40, 0.00, NULL);
INSERT INTO `orders` VALUES (221, 4, 'ORD1778546872490', 'COMPLETED', 9.20, 9.20, 9.20, 0.00, NULL);
INSERT INTO `orders` VALUES (222, 4, 'ORD1778546880103', 'COMPLETED', 66.40, 66.40, 66.40, 0.00, NULL);
INSERT INTO `orders` VALUES (223, 9, 'ORD1778546902843', 'COMPLETED', 21.60, 21.60, 21.60, 0.00, NULL);
INSERT INTO `orders` VALUES (224, 9, 'ORD1778546911014', 'COMPLETED', 28.60, 28.60, 28.60, 0.00, NULL);
INSERT INTO `orders` VALUES (225, 1, 'ORD1778547000562', 'COMPLETED', 1656.00, 1656.00, 1656.00, 0.00, NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 86 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `point_logs` VALUES (52, '2026-03-25 21:27:53.759175', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (53, '2026-03-25 21:33:34.698526', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (54, '2026-03-25 21:43:19.397627', '兑换取消返还: 10元代金券', 100, 'EXCHANGE', 'EARN', 1);
INSERT INTO `point_logs` VALUES (55, '2026-03-25 21:44:54.818036', '兑换奖励: 10元代金券', -100, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (56, '2026-04-27 14:46:18.122907', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (57, '2026-04-27 15:58:44.305520', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (58, '2026-04-27 15:58:44.319859', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (59, '2026-04-27 16:01:50.974462', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (60, '2026-04-27 16:01:50.984875', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (61, '2026-04-27 16:08:44.479029', '兑换奖励: 10元代金券', -100, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (62, '2026-04-27 16:10:35.314957', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (63, '2026-04-27 16:11:29.353127', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (64, '2026-04-28 11:18:32.698970', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (65, '2026-04-28 11:41:31.297695', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (66, '2026-04-28 11:57:40.155949', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (67, '2026-04-28 11:58:28.857160', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (68, '2026-04-28 12:03:06.780052', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 9);
INSERT INTO `point_logs` VALUES (69, '2026-04-28 12:05:49.662792', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 5);
INSERT INTO `point_logs` VALUES (70, '2026-04-28 12:06:17.613329', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 5);
INSERT INTO `point_logs` VALUES (71, '2026-04-28 12:06:48.883472', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 5);
INSERT INTO `point_logs` VALUES (72, '2026-04-28 12:07:29.651822', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 9);
INSERT INTO `point_logs` VALUES (73, '2026-04-28 12:10:23.659345', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (74, '2026-04-28 12:12:09.546908', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (75, '2026-05-09 22:19:37.291446', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 5);
INSERT INTO `point_logs` VALUES (76, '2026-05-11 13:17:03.659936', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (77, '2026-05-11 13:17:19.957422', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (78, '2026-05-12 00:08:55.913423', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (79, '2026-05-12 00:09:51.073840', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (80, '2026-05-12 00:09:51.083807', '评价奖励: 图文评价奖励', 20, 'REVIEW_REWARD', 'EARN', 1);
INSERT INTO `point_logs` VALUES (81, '2026-05-12 00:10:27.749060', '兑换奖励: 10元代金券', -100, 'EXCHANGE', 'SPEND', 1);
INSERT INTO `point_logs` VALUES (82, '2026-05-12 08:54:40.206858', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 3);
INSERT INTO `point_logs` VALUES (83, '2026-05-12 08:59:19.391216', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 9);
INSERT INTO `point_logs` VALUES (84, '2026-05-12 09:03:28.666458', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 9);
INSERT INTO `point_logs` VALUES (85, '2026-05-12 09:04:29.824246', '评价奖励: 基础评价奖励', 10, 'REVIEW_REWARD', 'EARN', 9);

-- ----------------------------
-- Table structure for promotion_categories
-- ----------------------------
DROP TABLE IF EXISTS `promotion_categories`;
CREATE TABLE `promotion_categories`  (
  `promotion_id` bigint NOT NULL,
  `category_id` bigint NOT NULL,
  INDEX `FKaqy93wdhopfuklq4l5o534xtv`(`category_id` ASC) USING BTREE,
  INDEX `FKoynbpufptkiqhk4n10x25fp3o`(`promotion_id` ASC) USING BTREE,
  CONSTRAINT `FKaqy93wdhopfuklq4l5o534xtv` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FKoynbpufptkiqhk4n10x25fp3o` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of promotion_categories
-- ----------------------------

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
INSERT INTO `promotion_dish_categories` VALUES (14, 'MAIN_DISH');
INSERT INTO `promotion_dish_categories` VALUES (20, 'MAIN_DISH');

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
-- Table structure for promotion_sub_categories
-- ----------------------------
DROP TABLE IF EXISTS `promotion_sub_categories`;
CREATE TABLE `promotion_sub_categories`  (
  `promotion_id` bigint NOT NULL,
  `sub_category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `FK1fcqtwrby63aomfmhtbp868nb`(`promotion_id` ASC) USING BTREE,
  CONSTRAINT `FK1fcqtwrby63aomfmhtbp868nb` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of promotion_sub_categories
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
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of promotions
-- ----------------------------
INSERT INTO `promotions` VALUES (13, '', 0.8, '2027-05-28 00:00:00.000000', NULL, NULL, b'1', '套餐', 0, NULL, '2026-04-08 00:00:00.000000', 'active', 'all', 0, 'combo');
INSERT INTO `promotions` VALUES (14, '开学大促销，全场八折！！！', 0.8, '2026-06-27 00:00:00.000000', 0, NULL, b'0', '开学促销', 79, 0, '2026-03-25 00:00:00.000000', 'active', 'all', 1630.8200000000002, 'discount');
INSERT INTO `promotions` VALUES (20, '', 0.8, '2026-06-27 00:00:00.000000', 20, NULL, b'0', '主食满20减5', 3, 5, '2026-05-10 00:00:00.000000', 'active', 'category', 15, 'full_reduction');

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
) ENGINE = InnoDB AUTO_INCREMENT = 121 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of review_items
-- ----------------------------
INSERT INTO `review_items` VALUES (65, '2026-03-25 21:27:53.705597', 5, 18, 41);
INSERT INTO `review_items` VALUES (66, '2026-03-25 21:33:34.668426', 2, 2, 42);
INSERT INTO `review_items` VALUES (67, '2026-03-25 21:33:34.668426', 2, 6, 42);
INSERT INTO `review_items` VALUES (73, '2026-04-28 11:18:32.620375', 5, 4, 48);
INSERT INTO `review_items` VALUES (74, '2026-04-28 11:18:32.623444', 5, 10, 48);
INSERT INTO `review_items` VALUES (75, '2026-04-28 11:18:32.624324', 5, 11, 48);
INSERT INTO `review_items` VALUES (76, '2026-04-28 11:18:32.626254', 5, 22, 48);
INSERT INTO `review_items` VALUES (77, '2026-04-28 11:41:31.222799', 5, 31, 49);
INSERT INTO `review_items` VALUES (78, '2026-04-28 11:57:40.131510', 5, 9, 50);
INSERT INTO `review_items` VALUES (79, '2026-04-28 11:58:28.803730', 5, 2, 51);
INSERT INTO `review_items` VALUES (80, '2026-04-28 12:03:06.747982', 5, 19, 52);
INSERT INTO `review_items` VALUES (81, '2026-04-28 12:05:49.644140', 5, 16, 53);
INSERT INTO `review_items` VALUES (82, '2026-04-28 12:06:17.589370', 4, 26, 54);
INSERT INTO `review_items` VALUES (83, '2026-04-28 12:06:48.863720', 4, 12, 55);
INSERT INTO `review_items` VALUES (84, '2026-04-28 12:07:29.623924', 4, 17, 56);
INSERT INTO `review_items` VALUES (85, '2026-04-28 12:07:29.624633', 5, 13, 56);
INSERT INTO `review_items` VALUES (86, '2026-04-28 12:10:23.572661', 5, 1, 57);
INSERT INTO `review_items` VALUES (87, '2026-04-28 12:10:23.572661', 5, 3, 57);
INSERT INTO `review_items` VALUES (88, '2026-04-28 12:10:23.573698', 5, 8, 57);
INSERT INTO `review_items` VALUES (89, '2026-04-28 12:10:23.574864', 5, 7, 57);
INSERT INTO `review_items` VALUES (90, '2026-04-28 12:10:23.575498', 5, 11, 57);
INSERT INTO `review_items` VALUES (91, '2026-04-28 12:10:23.576000', 5, 10, 57);
INSERT INTO `review_items` VALUES (92, '2026-04-28 12:10:23.576000', 5, 21, 57);
INSERT INTO `review_items` VALUES (93, '2026-04-28 12:10:23.577305', 5, 18, 57);
INSERT INTO `review_items` VALUES (94, '2026-04-28 12:10:23.578214', 5, 29, 57);
INSERT INTO `review_items` VALUES (95, '2026-04-28 12:10:23.578214', 5, 28, 57);
INSERT INTO `review_items` VALUES (96, '2026-04-28 12:12:09.496889', 5, 24, 58);
INSERT INTO `review_items` VALUES (97, '2026-04-28 12:12:09.498086', 5, 25, 58);
INSERT INTO `review_items` VALUES (98, '2026-04-28 12:12:09.498779', 5, 14, 58);
INSERT INTO `review_items` VALUES (99, '2026-04-28 12:12:09.499296', 5, 23, 58);
INSERT INTO `review_items` VALUES (100, '2026-04-28 12:12:09.499296', 5, 27, 58);
INSERT INTO `review_items` VALUES (101, '2026-04-28 12:12:09.500959', 5, 32, 58);
INSERT INTO `review_items` VALUES (102, '2026-04-28 15:56:49.389171', 5, 30, 59);
INSERT INTO `review_items` VALUES (103, '2026-04-28 20:54:20.459156', 5, 34, 60);
INSERT INTO `review_items` VALUES (104, '2026-05-09 22:19:37.214965', 5, 31, 61);
INSERT INTO `review_items` VALUES (105, '2026-05-09 22:19:37.223421', 5, 32, 61);
INSERT INTO `review_items` VALUES (106, '2026-05-11 13:17:03.526312', 5, 2, 62);
INSERT INTO `review_items` VALUES (107, '2026-05-11 13:17:19.878914', 5, 21, 63);
INSERT INTO `review_items` VALUES (108, '2026-05-11 13:17:19.880500', 5, 30, 63);
INSERT INTO `review_items` VALUES (109, '2026-05-11 13:17:19.880500', 5, 1, 63);
INSERT INTO `review_items` VALUES (110, '2026-05-11 13:18:44.215568', 5, 2, 64);
INSERT INTO `review_items` VALUES (111, '2026-05-11 13:18:44.215568', 5, 9, 64);
INSERT INTO `review_items` VALUES (113, '2026-05-12 00:09:51.043617', 5, 22, 66);
INSERT INTO `review_items` VALUES (114, '2026-05-12 08:54:40.146322', 5, 2, 67);
INSERT INTO `review_items` VALUES (119, '2026-05-12 09:04:29.791786', 2, 23, 70);
INSERT INTO `review_items` VALUES (120, '2026-05-12 09:04:29.794025', 2, 16, 70);

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
INSERT INTO `review_quick_tags` VALUES (41, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (41, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (42, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (42, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (48, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (48, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (49, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (49, '食材新鲜', NULL);
INSERT INTO `review_quick_tags` VALUES (50, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (50, '食材新鲜', NULL);
INSERT INTO `review_quick_tags` VALUES (51, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (51, '服务好', NULL);
INSERT INTO `review_quick_tags` VALUES (52, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (52, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (53, '口感鲜美', NULL);
INSERT INTO `review_quick_tags` VALUES (53, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (54, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (54, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (54, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (54, '口感鲜美', NULL);
INSERT INTO `review_quick_tags` VALUES (55, '价格实惠', NULL);
INSERT INTO `review_quick_tags` VALUES (55, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (56, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (56, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (56, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (58, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (58, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (59, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (59, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (61, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (61, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (62, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (62, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (63, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (63, '口感鲜美', NULL);
INSERT INTO `review_quick_tags` VALUES (64, '色泽诱人', NULL);
INSERT INTO `review_quick_tags` VALUES (64, '分量足', NULL);
INSERT INTO `review_quick_tags` VALUES (64, '服务好', NULL);
INSERT INTO `review_quick_tags` VALUES (66, '香气扑鼻', NULL);
INSERT INTO `review_quick_tags` VALUES (66, '味道好', NULL);
INSERT INTO `review_quick_tags` VALUES (67, '食材新鲜', NULL);
INSERT INTO `review_quick_tags` VALUES (67, '香气扑鼻', NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 83 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `review_reward_records` VALUES (53, '2026-03-25 21:27:53.751336', 10, 41, 1, 1);
INSERT INTO `review_reward_records` VALUES (54, '2026-03-25 21:33:34.690335', 10, 42, 1, 1);
INSERT INTO `review_reward_records` VALUES (62, '2026-04-28 11:18:32.688315', 10, 48, 1, 1);
INSERT INTO `review_reward_records` VALUES (63, '2026-04-28 11:41:31.273002', 10, 49, 1, 1);
INSERT INTO `review_reward_records` VALUES (64, '2026-04-28 11:57:40.151975', 10, 50, 1, 1);
INSERT INTO `review_reward_records` VALUES (65, '2026-04-28 11:58:28.851559', 10, 51, 1, 1);
INSERT INTO `review_reward_records` VALUES (66, '2026-04-28 12:03:06.774185', 10, 52, 1, 9);
INSERT INTO `review_reward_records` VALUES (67, '2026-04-28 12:05:49.660478', 10, 53, 1, 5);
INSERT INTO `review_reward_records` VALUES (68, '2026-04-28 12:06:17.608771', 10, 54, 1, 5);
INSERT INTO `review_reward_records` VALUES (69, '2026-04-28 12:06:48.881501', 10, 55, 1, 5);
INSERT INTO `review_reward_records` VALUES (70, '2026-04-28 12:07:29.648211', 10, 56, 1, 9);
INSERT INTO `review_reward_records` VALUES (71, '2026-04-28 12:10:23.654802', 10, 57, 1, 1);
INSERT INTO `review_reward_records` VALUES (72, '2026-04-28 12:12:09.542374', 20, 58, 2, 1);
INSERT INTO `review_reward_records` VALUES (73, '2026-05-09 22:19:37.277729', 10, 61, 1, 5);
INSERT INTO `review_reward_records` VALUES (74, '2026-05-11 13:17:03.650390', 10, 62, 1, 3);
INSERT INTO `review_reward_records` VALUES (75, '2026-05-11 13:17:19.948425', 10, 63, 1, 3);
INSERT INTO `review_reward_records` VALUES (77, '2026-05-12 00:09:51.070693', 10, 66, 1, 1);
INSERT INTO `review_reward_records` VALUES (78, '2026-05-12 00:09:51.080252', 20, 66, 2, 1);
INSERT INTO `review_reward_records` VALUES (79, '2026-05-12 08:54:40.196385', 10, 67, 1, 3);
INSERT INTO `review_reward_records` VALUES (82, '2026-05-12 09:04:29.820887', 10, 70, 1, 9);

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
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评价表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reviews
-- ----------------------------
INSERT INTO `reviews` VALUES (41, 1, 5, 5, 5, 5, 5, '很香', '[]', NULL, NULL, '2026-03-25 21:27:54', 'NORMAL', b'1', 20, 124);
INSERT INTO `reviews` VALUES (42, 1, 2, 2, 2, 2, 2, '真特么难吃，汤是馊的', '[]', '很抱歉给你带来不好的体验', '2026-03-25 21:47:38', '2026-03-25 21:33:35', 'NORMAL', b'1', 20, 112);
INSERT INTO `reviews` VALUES (48, 1, 5, 5, 5, 5, 5, '', '[]', '感谢好评', '2026-04-28 11:19:38', '2026-04-28 11:18:33', 'NORMAL', b'1', 0, 162);
INSERT INTO `reviews` VALUES (49, 1, 5, 5, 5, 5, 5, '虾仁很鲜美', '[]', NULL, NULL, '2026-04-28 11:41:31', 'NORMAL', b'1', 22, 163);
INSERT INTO `reviews` VALUES (50, 1, 5, 5, 5, 5, 5, '还行吧', '[]', NULL, NULL, '2026-04-28 11:57:40', 'NORMAL', b'1', 20, 164);
INSERT INTO `reviews` VALUES (51, 1, 5, 5, 5, 5, 5, '1111111', '[]', NULL, NULL, '2026-04-28 11:58:29', 'NORMAL', b'1', 20, 165);
INSERT INTO `reviews` VALUES (52, 9, 5, 5, 5, 5, 5, '香dry了', '[]', NULL, NULL, '2026-04-28 12:03:07', 'NORMAL', b'1', 20, 169);
INSERT INTO `reviews` VALUES (53, 5, 5, 5, 5, 5, 5, '太香啦', '[]', NULL, NULL, '2026-04-28 12:05:50', 'NORMAL', b'1', 20, 168);
INSERT INTO `reviews` VALUES (54, 5, 5, 5, 5, 5, 5, '师傅手艺真的不错', '[]', NULL, NULL, '2026-04-28 12:06:18', 'NORMAL', b'1', 22, 167);
INSERT INTO `reviews` VALUES (55, 5, 5, 3, 4, 4, 4, '味道不错，就是分量少了一点', '[]', NULL, NULL, '2026-04-28 12:06:49', 'NORMAL', b'1', 32, 166);
INSERT INTO `reviews` VALUES (56, 9, 5, 4, 4, 4, 4.25, '鸡有鸡味', '[]', NULL, NULL, '2026-04-28 12:07:30', 'NORMAL', b'1', 20, 170);
INSERT INTO `reviews` VALUES (57, 1, 5, 5, 5, 5, 5, '用户觉得很赞', '[]', NULL, NULL, '2026-04-28 12:10:24', 'NORMAL', b'1', 22, 173);
INSERT INTO `reviews` VALUES (58, 1, 5, 5, 5, 5, 5, '看起来就很好吃，吃起来更好吃', '[\"/uploads/f0df25f6-92d1-462a-a64c-7ffcf58b387d_屏幕截图 2026-01-23 222842.png\"]', '感谢支持', '2026-05-12 00:10:11', '2026-04-28 12:12:09', 'NORMAL', b'1', 52, 174);
INSERT INTO `reviews` VALUES (59, 1, 5, 5, 5, 5, 5, '好', '[]', NULL, NULL, '2026-04-28 15:56:49', 'NORMAL', b'0', 20, 176);
INSERT INTO `reviews` VALUES (60, 1, 5, 5, 5, 5, 5, '好喝', '[]', NULL, NULL, '2026-04-28 20:54:20', 'NORMAL', b'0', 20, 179);
INSERT INTO `reviews` VALUES (61, 5, 5, 5, 5, 5, 5, '鸡有鸡味', '[]', NULL, NULL, '2026-05-09 22:19:37', 'NORMAL', b'1', 20, 188);
INSERT INTO `reviews` VALUES (62, 3, 5, 5, 5, 5, 5, '好吃', '[]', NULL, NULL, '2026-05-11 13:17:04', 'NORMAL', b'1', 22, 114);
INSERT INTO `reviews` VALUES (63, 3, 5, 5, 5, 5, 5, '', '[]', NULL, NULL, '2026-05-11 13:17:20', 'NORMAL', b'1', 0, 20);
INSERT INTO `reviews` VALUES (64, 4, 5, 5, 5, 5, 5, '', '[]', NULL, NULL, '2026-05-11 13:18:44', 'NORMAL', b'0', 0, 27);
INSERT INTO `reviews` VALUES (66, 1, 5, 5, 5, 5, 5, '酸酸甜甜的很好吃', '[\"/uploads/65b7997e-5a71-4d42-95e8-e322df5c1f4a_f92966bf53f04e05566134e07b3fb554.jpg\"]', NULL, NULL, '2026-05-12 00:09:51', 'NORMAL', b'1', 42, 219);
INSERT INTO `reviews` VALUES (67, 3, 5, 5, 5, 5, 5, '好食', '[]', NULL, NULL, '2026-05-12 08:54:40', 'NORMAL', b'1', 20, 131);
INSERT INTO `reviews` VALUES (70, 9, 2, 2, 2, 2, 2, '真难吃', '[]', NULL, NULL, '2026-05-12 09:04:30', 'NORMAL', b'1', 20, 224);

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reward_exchanges
-- ----------------------------
INSERT INTO `reward_exchanges` VALUES (1, 1, 1, 'COMPLETED', '920e3a13-e977-42ff-a405-0e5cdf84fb0e', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 1, '2026-01-31 22:30:06', 38, 10.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-31 22:29:51', '2026-01-31 22:29:51', '2026-01-31 22:29:51');
INSERT INTO `reward_exchanges` VALUES (2, 1, 3, 'COMPLETED', '2d01cbef-1726-49bf-a847-e32419a9147e', 200, NULL, NULL, 0, NULL, NULL, NULL, 'DELIVERED', '顺丰快递发货', '杨翔宇', '17817171348', '东南大学成贤学院', NULL, NULL, NULL, '2026-02-02 22:39:17', '2026-03-25 21:40:59', '2026-03-25 21:40:59');
INSERT INTO `reward_exchanges` VALUES (3, 1, 4, 'COMPLETED', 'e9db4e29-075e-46b8-a2f7-678bd4af015f', 200, NULL, '', 0, NULL, NULL, NULL, 'DELIVERED', '', '杨翔宇', '17728997857', '东南大学成贤学院', NULL, NULL, NULL, '2026-02-07 15:12:53', '2026-02-07 15:19:12', '2026-02-07 15:19:12');
INSERT INTO `reward_exchanges` VALUES (4, 1, 1, 'COMPLETED', '7d148f39-f67f-416d-9992-aceeb7892516', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 1, '2026-02-08 00:14:29', 76, 10.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-08 00:13:57', '2026-02-08 00:13:57', '2026-02-08 00:13:57');
INSERT INTO `reward_exchanges` VALUES (5, 1, 3, 'COMPLETED', '917272ea-acd5-41e5-9357-794cc7d76fff', 200, NULL, NULL, 0, NULL, NULL, NULL, 'DELIVERED', '', '杨翔宇', '17817171348', '东南大学成贤学院', NULL, NULL, NULL, '2026-02-08 00:14:13', '2026-02-08 00:15:09', '2026-02-08 00:15:09');
INSERT INTO `reward_exchanges` VALUES (6, 1, 1, 'COMPLETED', '7cd83478-4096-4868-80ff-e8f246dd4467', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 1, '2026-02-11 10:31:02', 91, 7.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, '', '', NULL, '2026-02-11 10:30:43', '2026-03-25 21:44:28', '2026-03-25 21:44:28');
INSERT INTO `reward_exchanges` VALUES (7, 1, 5, 'COMPLETED', '4287fb84-aff2-4ec7-9577-45f15bf0d6b9', 30, 5.00, '', 1, '2026-02-19 20:09:37', 108, 5.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-19 20:08:11', '2026-02-19 20:09:12', '2026-02-19 20:09:12');
INSERT INTO `reward_exchanges` VALUES (8, 1, 1, 'COMPLETED', 'cba0da39-64d6-44f3-81d1-e9d574fd01f8', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 1, '2026-04-27 16:08:54', 151, 8.00, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-25 21:44:55', '2026-03-25 21:44:55', '2026-03-25 21:44:55');
INSERT INTO `reward_exchanges` VALUES (9, 1, 1, 'COMPLETED', 'da8c6cd4-1b84-4fb2-8304-50cb3a8393e7', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 0, NULL, NULL, NULL, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-27 16:08:44', '2026-04-27 16:08:44', '2026-04-27 16:08:44');
INSERT INTO `reward_exchanges` VALUES (10, 1, 1, 'COMPLETED', '1c13f339-89a3-40cb-9a51-f70808b4c3f8', 100, 10.00, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 0, NULL, NULL, NULL, 'DELIVERED', '系统自动发放', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-12 00:10:28', '2026-05-12 00:10:28', '2026-05-12 00:10:28');

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
INSERT INTO `rewards` VALUES (1, '10元代金券', '全场通用抵扣10元', 100, 45, 'https://images.unsplash.com/photo-1556742502-ec7c0e9f34b1?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80', 1, 'VOUCHER', 10.00, 0.00, '2026-01-30 00:00:00', '2032-02-20 00:00:00', 100, 100, 1, '{\"scope\":\"canteen\",\"note\":\"示例数据\"}', 2, 'AVAILABLE', '2026-01-31 22:01:50', '2026-03-25 21:44:49');
INSERT INTO `rewards` VALUES (2, '食堂实物奖品', '食堂联名马克杯', 300, 5, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80', 2, 'OTHER', NULL, NULL, NULL, NULL, 0, 1, 1, '', 3, 'AVAILABLE', '2026-01-31 22:01:50', '2026-05-12 08:57:01');
INSERT INTO `rewards` VALUES (3, '数字周边礼包', '校园数字周边兑换码', 200, 18, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', 3, 'OTHER', NULL, NULL, NULL, NULL, 0, 2, 1, NULL, 0, 'AVAILABLE', '2026-01-31 22:01:50', '2026-01-31 22:01:50');
INSERT INTO `rewards` VALUES (4, '百科全书', '', 200, 29, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80', 2, 'OTHER', NULL, NULL, '2026-02-07 00:00:00', '2027-03-20 00:00:00', 5, 2, 1, '', 1, 'DELETED', '2026-02-07 15:12:11', '2026-02-08 00:12:48');
INSERT INTO `rewards` VALUES (5, '5元代价券', '5元代金券', 30, 29, 'https://images.unsplash.com/photo-1556742502-ec7c0e9f34b1?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80', 1, 'VOUCHER', 5.00, 5.00, '2026-02-18 00:00:00', '2026-03-28 00:00:00', 30, 5, 1, '', 3, 'DELETED', '2026-02-18 20:37:29', '2026-02-19 20:24:04');
INSERT INTO `rewards` VALUES (6, '3元代金券', '', 10, 30, 'https://images.unsplash.com/photo-1556742502-ec7c0e9f34b1?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80', 1, 'VOUCHER', 3.00, 3.00, '2026-02-20 00:00:00', '2026-03-18 00:00:00', 6, 4, 1, '', 1, 'DELETED', '2026-02-20 21:14:21', '2026-02-20 21:14:37');

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户偏好画像表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_profile
-- ----------------------------
INSERT INTO `user_profile` VALUES (1, 1, '2026-01-14 13:20:28', '2026-05-12 08:47:23', '不吃香菜', '不吃香菜,辣度:4,川菜,鲜香,东北菜,甜度:1', NULL, NULL, 0, 0, 4);
INSERT INTO `user_profile` VALUES (2, 3, '2026-01-14 13:20:28', '2026-05-11 13:17:39', '不吃牛肉，不吃海鲜', '清淡,不吃牛肉，不吃海鲜,辣度:2,粤菜,甜度:4', NULL, NULL, 0, 0, 2);
INSERT INTO `user_profile` VALUES (3, 4, '2026-01-14 13:20:28', '2026-05-09 22:12:49', '', '徽菜,辣度:4,川菜,重口,高蛋白,甜度:2', NULL, NULL, 0, 0, 4);
INSERT INTO `user_profile` VALUES (4, 7, '2026-01-14 13:52:08', '2026-05-09 22:13:41', '不吃油腻食物', '川菜,辣度:2,重口,不吃油腻食物,高蛋白,甜度:1', NULL, NULL, 0, 0, 2);
INSERT INTO `user_profile` VALUES (5, 8, '2026-02-02 22:10:31', '2026-05-09 22:13:49', '不吃海鲜', '无麸质,辣度:3,川菜,甜度:2,东北菜,低脂,不吃海鲜', NULL, NULL, 0, 0, 3);
INSERT INTO `user_profile` VALUES (7, 11, '2026-02-02 22:10:51', '2026-05-09 22:13:34', '不吃蒜', '辣度:5,健身餐,湘菜,不吃蒜,苏菜,甜度:1', NULL, NULL, 0, 0, 5);
INSERT INTO `user_profile` VALUES (8, 5, '2026-02-02 22:11:02', '2026-05-09 22:13:02', '不吃辣，不吃蒜', '素食,辣度:1,粤菜,甜度:3,不吃辣，不吃蒜', NULL, NULL, 1, 0, 1);
INSERT INTO `user_profile` VALUES (9, 10, '2026-02-02 22:11:12', '2026-05-09 22:13:59', '素食主义', '素食,辣度:4,素食主义,粤菜,东北菜,甜度:1', NULL, NULL, 1, 0, 4);
INSERT INTO `user_profile` VALUES (10, 9, '2026-02-02 22:11:17', '2026-05-09 22:13:54', '不吃香菜，不吃葱', '清淡,徽菜,辣度:1,不吃香菜，不吃葱,粤菜,健康,甜度:4,鲜香', NULL, NULL, 0, 0, 1);
INSERT INTO `user_profile` VALUES (13, 2, '2026-02-09 14:19:44', '2026-04-27 15:17:29', '', '素食,辣度:3,川菜,重口,粤菜,甜度:3', NULL, NULL, 1, 0, 3);
INSERT INTO `user_profile` VALUES (15, 25, '2026-04-27 15:17:58', '2026-05-12 08:52:40', '海鲜过敏', '徽菜,辣度:4,健身餐,重口,海鲜过敏,甜度:1', NULL, NULL, 0, 0, 4);

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
) ENGINE = InnoDB AUTO_INCREMENT = 35 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin001', 'admin', '$2a$10$hlvdQeYB3oOqSjWqoMJtLumiwGilirHjZ9jO9CstkFcVwOfvjPgR2', '18813440381', '3198035651@qq.com', 'ADMIN', 4, 1, '不吃香菜', '2025-11-17 17:16:18', '2026-05-12 08:47:23', '2026-01-02 22:59:25.197476', 90, 'active', '/uploads/47008f05-ad3c-4290-af1a-f56b0a3d7784.png');
INSERT INTO `users` VALUES (2, 'wm001', '窗口管理员', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '18813440381', '3198035651@qq.com', 'WINDOW_MANAGER', 3, 3, '', '2025-11-17 17:16:18', '2026-04-27 15:17:29', NULL, NULL, 'active', 'data:image/png;base64,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');
INSERT INTO `users` VALUES (3, '2021001', '张三', '$2a$10$UbqJXbjO.e9HE12spP5k4eJ.THeM0YcYXybB9Ana7ghxO2Gq4qrMe', '13800138001', 'zhangsan@example.com', 'STUDENT', 2, 4, '不吃牛肉，不吃海鲜', '2025-11-17 17:16:18', '2026-05-11 13:17:39', NULL, 110, 'active', '/uploads/17a225b4-da36-4b1a-a66f-de42858dab7c.jpg');
INSERT INTO `users` VALUES (4, '2021002', '李四', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138002', 'lisi@example.com', 'STUDENT', 4, 2, '', '2025-11-17 17:16:18', '2026-05-09 22:12:49', NULL, NULL, 'active', '/uploads/5119900f-bc01-4c22-bf61-97641c3fd3e6.jpg');
INSERT INTO `users` VALUES (5, '2021003', '王五', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138003', 'wangwu@example.com', 'STUDENT', 1, 3, '不吃辣，不吃蒜', '2025-11-20 11:00:17', '2026-05-09 22:13:02', NULL, 40, 'active', '/uploads/f2312142-6870-4a9d-ae13-668c5c6186cc.jpg');
INSERT INTO `users` VALUES (7, '2021005', '孙七', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138005', 'sunqi@example.com', 'STUDENT', 2, 1, '不吃油腻食物', '2025-11-20 11:00:17', '2026-05-09 22:13:41', NULL, 10, 'active', '/uploads/4222112e-1ce7-4536-bb4b-77ab222a0786.jpg');
INSERT INTO `users` VALUES (8, '2021006', '周八', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138006', 'zhouba@example.com', 'STUDENT', 3, 2, '不吃海鲜', '2025-11-20 11:00:17', '2026-05-09 22:13:49', NULL, NULL, 'active', '/uploads/dc5a5e69-052c-4b31-b4cb-e2287a935d6b.jpg');
INSERT INTO `users` VALUES (9, '2021007', '吴九', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138007', 'wujiu@example.com', 'STUDENT', 1, 4, '不吃香菜，不吃葱', '2025-11-20 11:00:17', '2026-05-09 22:13:54', NULL, 50, 'active', '/uploads/23c29f95-04f4-4a47-b60c-adc5756fbce5.jpg');
INSERT INTO `users` VALUES (10, '2021008', '郑十', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138008', 'zhengshi@example.com', 'STUDENT', 4, 1, '素食主义', '2025-11-20 11:00:17', '2026-05-09 22:13:59', NULL, NULL, 'active', '/uploads/32360ead-0d31-4468-b0c4-31a04f82cfe6.jpg');
INSERT INTO `users` VALUES (11, '2021009', '钱六', '$2a$10$BBAa8lwC08Po7Bs.GyZ9X.sv0T0W2ikB4/m6gCvzt2Na7iR6P9qt2', '13800138009', 'qianliui@example.com', 'STUDENT', 5, 1, '不吃蒜', '2025-11-20 11:00:17', '2026-05-09 22:13:34', NULL, NULL, 'active', '/uploads/9110b42c-d976-48bf-91e1-2e89fcaba243.jpg');
INSERT INTO `users` VALUES (25, '2024001', '宋十一', '$2a$10$7uzajD3qDCbRtVUUrkBHyOu0wEcWyEup2gE80Raq6xFp1dWT98tQC', '13800138000', 'teststudent@example.com', 'STUDENT', 4, 1, '海鲜过敏', '2026-03-11 11:28:41', '2026-05-12 08:52:40', NULL, 20, 'inactive', '/uploads/e028b4aa-536a-4216-94e5-2500629ff1cf.jpg');

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
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of windows
-- ----------------------------
INSERT INTO `windows` VALUES (1, 1, '第一食堂', '2026-01-06 13:10:50.649357', '一楼东侧', NULL, '上海菜窗口', '08:00-18:00', 'OPEN', '2026-05-11 13:21:44.348062', '红姐');
INSERT INTO `windows` VALUES (2, 1, '第一食堂', '2026-01-06 13:10:50.680724', '三楼东侧', NULL, '川菜窗口', '08:00-18:00', 'OPEN', '2026-04-27 14:51:07.723886', '张姐');
INSERT INTO `windows` VALUES (3, 1, '第一食堂', '2026-01-06 13:10:50.686833', '一楼东侧', NULL, '早餐窗口', '06:30-10:30', 'OPEN', '2026-01-06 13:10:50.686833', NULL);
INSERT INTO `windows` VALUES (4, 1, '第一食堂', '2026-01-06 13:10:50.692955', '二楼东侧', 16, '浙菜窗口', '08:00-18:00', 'OPEN', '2026-05-10 19:38:54.033356', '胡');
INSERT INTO `windows` VALUES (5, 1, '第一食堂', '2026-01-06 13:10:50.697790', '一楼东侧', NULL, '湘菜窗口', '08:00-18:00', 'OPEN', '2026-01-06 13:10:50.697790', NULL);
INSERT INTO `windows` VALUES (6, 1, '第一食堂', '2026-01-06 13:10:50.702352', '二楼东侧', 12, '特色菜窗口', '08:00-18:00', 'OPEN', '2026-05-10 16:42:20.077424', '鱼');
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
