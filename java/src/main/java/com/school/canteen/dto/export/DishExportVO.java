package com.school.canteen.dto.export;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 菜品导出VO，用于Excel导出 */
@Data
public class DishExportVO {
    @ExcelProperty("ID")
    @ColumnWidth(10)
    private Long id;

    @ExcelProperty("菜品名称")
    @ColumnWidth(20)
    private String name;

    @ExcelProperty("价格")
    @ColumnWidth(10)
    private BigDecimal price;

    @ExcelProperty("分类")
    @ColumnWidth(15)
    private String category;

    @ExcelProperty("食堂")
    @ColumnWidth(15)
    private String canteenName;

    @ExcelProperty("窗口")
    @ColumnWidth(15)
    private String windowName;

    @ExcelProperty("每日限量")
    @ColumnWidth(10)
    private Integer dailyLimit;

    @ExcelProperty("当前库存")
    @ColumnWidth(10)
    private Integer stock;

    @ExcelProperty("销量")
    @ColumnWidth(10)
    private Integer salesCount;

    @ExcelProperty("评分")
    @ColumnWidth(10)
    private Double averageRating;

    @ExcelProperty("状态")
    @ColumnWidth(15)
    private String status;

    @ExcelProperty("描述")
    @ColumnWidth(30)
    private String description;

    @ExcelProperty("创建时间")
    @ColumnWidth(20)
    private String createTime;
}
