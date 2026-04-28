# 摘  要

随着高校信息化建设和智慧校园发展不断深入，校园食堂服务正在由传统人工管理模式向数字化、智能化方向转变。针对当前校园食堂场景中存在的菜品信息分散、用户选择成本高、个性化服务不足、平台运营数据利用率不高等问题，本文设计并实现了一套校园食堂智能推荐系统。该系统以提升用户就餐决策效率和平台运营管理能力为目标，将菜品管理、订单处理、评价反馈、积分运营与个性化推荐等功能进行有机整合。

本文首先结合校园食堂业务特点，对普通用户、窗口管理者和平台管理员三类角色的需求进行了分析，并在此基础上完成了系统总体架构设计、功能模块设计、数据库设计和业务流程设计。在系统实现方面，后端采用 Spring Boot 框架构建 RESTful 服务，前端采用 Vue 3 技术实现用户端与管理端页面，数据库采用 MySQL 进行业务数据存储，并结合 Redis 提升系统访问效率和数据响应性能。在推荐机制方面，系统综合考虑用户历史行为、菜品内容特征、热门程度以及时段情景等因素，实现了面向校园就餐场景的智能推荐功能。

在系统测试阶段，本文从功能测试和非功能性测试两个方面对系统进行了验证。测试结果表明，该系统能够较好地实现用户登录、菜品浏览、智能推荐、购物车管理、订单处理、评价反馈、积分兑换和后台管理等核心功能，并在权限控制、数据一致性、基本性能和交互可用性方面达到预期目标。研究结果说明，将推荐技术应用于校园食堂场景具有较强的可行性和实际应用价值。

本系统不仅能够改善学生用户的选餐体验，提高校园食堂服务效率，也为高校智慧后勤和智慧餐饮平台建设提供了可参考的设计思路和实现方案。

关键词：校园食堂；智能推荐；Spring Boot；Vue 3；个性化推荐；智慧校园

## Abstract

With the continuous development of campus informatization and smart campus construction, canteen services in universities are gradually shifting from traditional manual management to digital and intelligent service models. To address the problems in current campus canteen scenarios, such as scattered dish information, high decision-making cost for users, insufficient personalized services, and low utilization of operational data, this paper designs and implements an intelligent recommendation system for campus canteens. The system aims to improve dining decision-making efficiency for users and operational management capability for the platform by integrating dish management, order processing, review feedback, points operation, and personalized recommendation.

First, according to the business characteristics of campus canteens, this paper analyzes the requirements of three types of roles: ordinary users, stall managers, and platform administrators. On this basis, the overall system architecture, functional modules, database structure, and business processes are designed. In terms of implementation, the backend is developed with the Spring Boot framework to provide RESTful services, and the frontend is implemented with Vue 3 to build both user-side and admin-side interfaces. MySQL is used for business data storage, while Redis is introduced to improve access efficiency and response performance. For recommendation, the system comprehensively considers user historical behavior, dish content features, popularity, and time-based contextual factors, so as to realize intelligent recommendation for campus dining scenarios.

During the system testing phase, both functional testing and non-functional testing are carried out. The results show that the system can effectively support core functions including user login, dish browsing, intelligent recommendation, shopping cart management, order processing, review feedback, points redemption, and backend administration. It also achieves the expected goals in access control, data consistency, basic performance, and interaction usability. The research demonstrates that applying recommendation technology to campus canteen scenarios is both feasible and practically valuable.

The system can not only improve the dining selection experience of students and enhance the service efficiency of campus canteens, but also provide a useful reference for the construction of smart logistics and smart catering platforms in universities.

Key words: campus canteen; intelligent recommendation; Spring Boot; Vue 3; personalized recommendation; smart campus
