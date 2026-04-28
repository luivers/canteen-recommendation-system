package com.school.canteen.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/** 文件上传控制器 — 处理图片等文件上传，生成 UUID 文件名并返回访问 URL */
@RestController
@RequestMapping("/api")
public class FileUploadController {

    @Value("${file.upload-dir:./uploads/}")
    private String uploadDir;

    /**
     * 上传文件并返回访问URL
     */
    @PostMapping("/upload")
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "文件不能为空"));
        }

        try {
            // 确保目录存在
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // 生成唯一文件名
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String newFilename = UUID.randomUUID().toString() + extension;

            // 保存文件
            Path targetLocation = uploadPath.resolve(newFilename);
            Files.copy(file.getInputStream(), targetLocation);

            // 返回访问 URL
            // 假设 StaticResourceConfig 映射了 /uploads/** 到 uploadDir
            String fileUrl = "/uploads/" + newFilename;

            Map<String, Object> response = new HashMap<>();
            response.put("url", fileUrl);
            response.put("message", "上传成功");
            
            return ResponseEntity.ok(response);

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "文件上传失败: " + e.getMessage()));
        }
    }
}
