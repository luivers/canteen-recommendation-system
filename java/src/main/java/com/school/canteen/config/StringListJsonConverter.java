package com.school.canteen.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

import java.util.ArrayList;
import java.util.List;

/** JPA属性转换器，将List<String>与JSON字符串互转 */
@Converter
public class StringListJsonConverter implements AttributeConverter<List<String>, String> {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final TypeReference<List<String>> LIST_TYPE = new TypeReference<>() {};

    @Override
    public String convertToDatabaseColumn(List<String> attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return "[]";
        }
        try {
            return OBJECT_MAPPER.writeValueAsString(attribute);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to serialize imageUrls", e);
        }
    }

    @Override
    public List<String> convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isBlank()) {
            return new ArrayList<>();
        }
        try {
            return OBJECT_MAPPER.readValue(dbData, LIST_TYPE);
        } catch (Exception e) {
            String trimmed = dbData.trim();
            if (trimmed.contains(",")) {
                String[] parts = trimmed.split(",");
                List<String> list = new ArrayList<>();
                for (String p : parts) {
                    String v = p.trim();
                    if (!v.isEmpty()) {
                        list.add(v);
                    }
                }
                return list;
            }
            return new ArrayList<>(List.of(trimmed));
        }
    }
}
