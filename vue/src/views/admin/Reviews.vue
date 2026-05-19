<template>
  <div class="reviews-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">评价管理</h1>
      <div class="header-actions">
        <el-button @click="exportData">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="订单号">
          <el-input
            v-model="searchForm.orderNumber"
            placeholder="请输入订单号"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input
            v-model="searchForm.username"
            placeholder="请输入用户名"
            clearable
            style="width: 150px"
          />
        </el-form-item>
        <el-form-item label="评分">
          <el-rate
            v-model="searchForm.rating"
            :colors="['#99A9BF', '#F7BA2A', '#FF9900']"
            :texts="rateTexts"
            show-text
            clearable
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 120px">
            <el-option label="正常" value="NORMAL" />
            <el-option label="预警" value="WARNING" />
            <el-option label="隐藏" value="HIDDEN" />
          </el-select>
        </el-form-item>
        <el-form-item label="评价时间">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 评价统计 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #409eff">
              <el-icon><ChatDotRound /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalReviews }}</div>
              <div class="stat-label">总评价数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #67c23a">
              <el-icon><Star /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.avgRating.toFixed(1) }}</div>
              <div class="stat-label">平均评分</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #e6a23c">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.activeUsers }}</div>
              <div class="stat-label">活跃评价用户</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #f56c6c">
              <el-icon><Food /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.reviewedOrders }}</div>
              <div class="stat-label">被评价订单</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 评价列表 -->
    <el-card>
      <template #header>
        <span>评价列表</span>
      </template>

      <el-table v-loading="loading" :data="reviews" style="width: 100%" :row-class-name="tableRowClassName">
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="orderNumber" label="订单号" width="160" />
        <el-table-column prop="username" label="用户" width="120" />
        <el-table-column prop="rating" label="评分" width="180">
          <template #default="scope">
            <el-rate
              v-model="scope.row.rating"
              disabled
              show-score
              text-color="#ff9900"
              score-template="{value}"
            />
          </template>
        </el-table-column>
        <el-table-column label="图片" width="140">
          <template #default="scope">
            <div
              v-if="scope.row.imageUrls && scope.row.imageUrls.length"
              class="review-images-cell"
            >
              <el-image
                :src="toImageUrl(scope.row.imageUrls[0])"
                :preview-src-list="buildPreviewSrcList(scope.row.imageUrls)"
                fit="cover"
                class="review-img-thumb"
              >
                <template #error>
                  <div class="image-slot">加载失败</div>
                </template>
              </el-image>
              <span
                v-if="scope.row.imageUrls.length > 1"
                class="review-img-more"
              >
                +{{ scope.row.imageUrls.length - 1 }}
              </span>
            </div>
            <span v-else>—</span>
          </template>
        </el-table-column>
        <el-table-column
          prop="content"
          label="评价内容"
          min-width="200"
          show-overflow-tooltip
        />
        <el-table-column label="标签" width="150">
          <template #default="scope">
            <div class="tags-container">
              <el-tag
                v-for="tag in scope.row.tags"
                :key="tag"
                size="small"
                style="margin: 2px"
              >
                {{ tag }}
              </el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column
          prop="reply"
          label="食堂回复"
          min-width="150"
          show-overflow-tooltip
        />
        <el-table-column prop="createdAt" label="评价时间" width="180">
          <template #default="scope">
            {{ formatTime(scope.row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button type="primary" link @click="handleViewDetail(scope.row)">
              查看
            </el-button>
            <el-button type="primary" link @click="handleReply(scope.row)"
              >回复</el-button
            >
            <el-button
              v-if="scope.row.status === 'WARNING'"
              type="success"
              link
              @click="handleResolveWarning(scope.row)"
            >
              解除预警
            </el-button>
            <el-button
              :type="scope.row.status === 'HIDDEN' ? 'success' : 'warning'"
              link
              @click="handleToggleStatus(scope.row)"
            >
              {{ scope.row.status === "HIDDEN" ? "显示" : "隐藏" }}
            </el-button>
            <el-button type="danger" link @click="handleDelete(scope.row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @update:page-size="handleSizeChange"
          @update:current-page="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 评价详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="评价详情" width="700px">
      <div v-if="currentReviewDetail" class="review-detail-content">
        <!-- 基本信息 -->
        <el-descriptions :column="2" border class="mb-20">
          <el-descriptions-item label="订单号">
            {{ currentReviewDetail.orderNumber }}
          </el-descriptions-item>
          <el-descriptions-item label="用户名">
            {{ currentReviewDetail.username }}
          </el-descriptions-item>
          <el-descriptions-item label="评价时间">
            {{ formatTime(currentReviewDetail.createdAt) }}
          </el-descriptions-item>
          <el-descriptions-item label="综合评分">
            <el-rate
              v-model="currentReviewDetail.rating"
              disabled
              show-score
              text-color="#ff9900"
              score-template="{value}"
            />
          </el-descriptions-item>
        </el-descriptions>

        <!-- 详细评分 -->
        <div class="detail-section">
          <h4>详细评分</h4>
          <el-row :gutter="20">
            <el-col :span="6">
              <div class="rating-item">
                <span class="label">口味:</span>
                <el-rate
                  v-model="currentReviewDetail.tasteRating"
                  disabled
                  show-score
                  text-color="#ff9900"
                />
              </div>
            </el-col>
            <el-col :span="6">
              <div class="rating-item">
                <span class="label">份量:</span>
                <el-rate
                  v-model="currentReviewDetail.portionRating"
                  disabled
                  show-score
                  text-color="#ff9900"
                />
              </div>
            </el-col>
            <el-col :span="6">
              <div class="rating-item">
                <span class="label">价格:</span>
                <el-rate
                  v-model="currentReviewDetail.priceRating"
                  disabled
                  show-score
                  text-color="#ff9900"
                />
              </div>
            </el-col>
            <el-col :span="6">
              <div class="rating-item">
                <span class="label">卫生:</span>
                <el-rate
                  v-model="currentReviewDetail.hygieneRating"
                  disabled
                  show-score
                  text-color="#ff9900"
                />
              </div>
            </el-col>
          </el-row>
        </div>

        <!-- 菜品评分 -->
        <div
          v-if="currentReviewDetail.items && currentReviewDetail.items.length > 0"
          class="detail-section"
        >
          <h4>菜品评分</h4>
          <el-table :data="currentReviewDetail.items" style="width: 100%" border>
            <el-table-column label="菜品名称">
              <template #default="{ row }">
                {{ row.dish ? row.dish.name : "未知菜品" }}
              </template>
            </el-table-column>
            <el-table-column label="评分" width="200">
              <template #default="{ row }">
                <el-rate
                  v-model="row.rating"
                  disabled
                  show-score
                  text-color="#ff9900"
                />
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 评价内容 -->
        <div class="detail-section">
          <h4>评价内容</h4>
          <div class="content-box">
            {{ currentReviewDetail.content }}
          </div>
          
          <!-- 标签 -->
          <div
            v-if="currentReviewDetail.tags && currentReviewDetail.tags.length > 0"
            class="tags-box"
          >
            <el-tag
              v-for="tag in currentReviewDetail.tags"
              :key="tag"
              size="small"
              effect="plain"
            >
              {{ tag }}
            </el-tag>
          </div>

          <!-- 图片 -->
          <div
            v-if="currentReviewDetail.imageUrls && currentReviewDetail.imageUrls.length > 0"
            class="images-box"
          >
            <el-image
              v-for="(url, idx) in currentReviewDetail.imageUrls"
              :key="idx"
              :src="toImageUrl(url)"
              :preview-src-list="buildPreviewSrcList(currentReviewDetail.imageUrls)"
              fit="cover"
              class="detail-img"
              :initial-index="idx"
            >
              <template #error>
                <div class="image-slot">加载失败</div>
              </template>
            </el-image>
          </div>
        </div>

        <!-- 商家回复 -->
        <div v-if="currentReviewDetail.reply" class="detail-section">
          <h4>商家回复</h4>
          <div class="reply-box">
            {{ currentReviewDetail.reply }}
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
        <el-button
          v-if="!currentReviewDetail?.reply"
          type="primary"
          @click="
            detailDialogVisible = false;
            handleReply(currentReviewDetail);
          "
        >
          去回复
        </el-button>
      </template>
    </el-dialog>

    <!-- 回复对话框 -->
    <el-dialog v-model="replyDialogVisible" title="回复评价" width="600px">
      <div v-if="currentReview" class="review-info">
        <div class="review-header">
          <h4>{{ currentReview.orderNumber }}</h4>
          <div class="review-meta">
            <span>用户: {{ currentReview.username }}</span>
            <span
              >评分:
              <el-rate v-model="currentReview.rating" disabled size="small" />
            </span>
          </div>
        </div>

        <div class="review-content">
          <p><strong>评价内容:</strong> {{ currentReview.content }}</p>
          <div
            v-if="currentReview.imageUrls && currentReview.imageUrls.length"
            class="review-images"
          >
            <el-image
              v-for="(url, idx) in currentReview.imageUrls"
              :key="idx"
              :src="toImageUrl(url)"
              :preview-src-list="buildPreviewSrcList(currentReview.imageUrls)"
              fit="cover"
              class="review-img"
            >
              <template #error>
                <div class="image-slot">加载失败</div>
              </template>
            </el-image>
          </div>
          <div v-if="currentReview.tags && currentReview.tags.length > 0">
            <strong>标签:</strong>
            <el-tag
              v-for="tag in currentReview.tags"
              :key="tag"
              size="small"
              style="margin: 2px"
            >
              {{ tag }}
            </el-tag>
          </div>
        </div>

        <el-form :model="replyForm" label-width="80px">
          <el-form-item label="回复内容">
            <el-input
              v-model="replyForm.content"
              type="textarea"
              :rows="4"
              placeholder="请输入回复内容"
              maxlength="500"
              show-word-limit
            />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <el-button @click="replyDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="submitting"
          @click="handleReplySubmit"
        >
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { useRoute } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Download,
  ChatDotRound,
  Star,
  User,
  Food,
  Hide,
  View,
} from "@element-plus/icons-vue";
import { reviewApi } from "@/api/review";
import api from "@/api";

const route = useRoute();
const loading = ref(false);
const replyDialogVisible = ref(false);
const detailDialogVisible = ref(false);
const submitting = ref(false);

const searchForm = reactive({
  orderNumber: "",
  username: "",
  rating: null,
  status: "",
  dateRange: [],
});

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0,
});

const stats = reactive({
  totalReviews: 0,
  avgRating: 0,
  activeUsers: 0,
  reviewedOrders: 0,
});

const reviews = ref([]);
const currentReview = ref(null);
const currentReviewDetail = ref(null);
const replyForm = reactive({
  content: "",
});

const rateTexts = ["很差", "较差", "一般", "良好", "优秀"];

const toImageUrl = (url) => {
  if (!url) return "";
  if (
    url.startsWith("http://") ||
    url.startsWith("https://") ||
    url.startsWith("data:") ||
    url.startsWith("//")
  ) {
    return url;
  }
  if (url.startsWith("/")) {
    return `${api.defaults.baseURL}${url}`;
  }
  return `${api.defaults.baseURL}/uploads/${url}`;
};

const buildPreviewSrcList = (urls) => {
  return (Array.isArray(urls) ? urls : []).map(toImageUrl).filter(Boolean);
};

// 获取状态类型
const getStatusType = (status) => {
  const map = {
    NORMAL: "success",
    HIDDEN: "info",
    SPAM: "danger",
    WARNING: "warning",
    REMOVED: "danger",
  };
  return map[status] || "info";
};

// 获取状态文本
const getStatusText = (status) => {
  const map = {
    NORMAL: "正常",
    HIDDEN: "已隐藏",
    SPAM: "垃圾评价",
    WARNING: "预警",
    REMOVED: "已删除",
  };
  return map[status] || status;
};

const tableRowClassName = ({ row }) => {
  if (row.status === "WARNING") {
    return "warning-row";
  }
  return "";
};

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return "";
  return new Date(timeStr).toLocaleString("zh-CN");
};

// 搜索评价
const handleSearch = () => {
  pagination.current = 1;
  loadReviews();
};

// 重置搜索
const handleReset = () => {
  Object.keys(searchForm).forEach((key) => {
    searchForm[key] = "";
  });
  searchForm.rating = null;
  searchForm.status = "";
  searchForm.dateRange = [];
  pagination.current = 1;
  loadReviews();
};

// 加载评价列表
const loadReviews = async () => {
  loading.value = true;
  try {
    const params = {
      page: pagination.current - 1, // Spring Boot page starts from 0
      size: pagination.size,
      orderNumber: searchForm.orderNumber || undefined,
      username: searchForm.username || undefined,
      rating: searchForm.rating || undefined,
      status: searchForm.status || undefined,
      startDate:
        searchForm.dateRange && searchForm.dateRange[0]
          ? searchForm.dateRange[0] + " 00:00:00"
          : undefined,
      endDate:
        searchForm.dateRange && searchForm.dateRange[1]
          ? searchForm.dateRange[1] + " 23:59:59"
          : undefined,
    };

    const res = await reviewApi.getAllReviews(params);
    const { data, total } = res.data || {};

    // 映射后端数据到前端格式
    reviews.value = (Array.isArray(data) ? data : []).map((item) => ({
      id: item.id,
      orderId: item.order?.id,
      orderNumber: item.order?.orderNumber || `订单${item.order?.id || ""}`,
      username: item.user?.username || "未知用户",
      rating: item.overallRating || 0,
      tasteRating: item.tasteRating || 0,
      portionRating: item.portionRating || 0,
      priceRating: item.priceRating || 0,
      hygieneRating: item.hygieneRating || 0,
      imageUrls: Array.isArray(item.imageUrls) ? item.imageUrls : [],
      content: item.comment,
      tags: item.quickTags || [],
      reply: item.canteenReply,
      status: item.status || "NORMAL",
      createdAt: item.createTime,
      items: item.items || [],
    }));

    pagination.total = total || 0;

    // 更新统计信息 (注意：这里只是当前页的统计，理想情况下应该有单独的统计接口)
    // 暂时保持简单，或者可以请求所有数据来统计（不推荐），或者后端提供
    // 这里简单更新总数
    stats.totalReviews = total || 0;
    if (reviews.value.length > 0) {
      stats.avgRating =
        reviews.value.reduce((sum, review) => sum + review.rating, 0) /
        reviews.value.length;
      stats.activeUsers = new Set(
        reviews.value.map((review) => review.username),
      ).size;
      stats.reviewedOrders = new Set(
        reviews.value.map((review) => review.orderId),
      ).size;
    }
  } catch (error) {
    console.error("Failed to load reviews:", error);
    ElMessage.error("加载评价列表失败");
  } finally {
    loading.value = false;
  }
};

// 查看评价详情
const handleViewDetail = (review) => {
  currentReviewDetail.value = review;
  detailDialogVisible.value = true;
};

// 回复评价
const handleReply = (review) => {
  currentReview.value = review;
  replyForm.content = review.reply || "";
  replyDialogVisible.value = true;
};

// 提交回复
const handleReplySubmit = async () => {
  if (!replyForm.content.trim()) {
    ElMessage.warning("请输入回复内容");
    return;
  }

  submitting.value = true;
  try {
    await reviewApi.replyToReview(currentReview.value.id, replyForm.content);
    ElMessage.success("回复成功");
    replyDialogVisible.value = false;
    loadReviews(); // 刷新列表
  } catch (error) {
    console.error("Reply failed:", error);
    ElMessage.error("回复失败");
  } finally {
    submitting.value = false;
  }
};

// 解除预警
const handleResolveWarning = async (review) => {
  try {
    await ElMessageBox.confirm("确定要解除这条评价的预警状态吗？", "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "info",
    });

    await reviewApi.updateReviewStatus(review.id, "NORMAL");
    ElMessage.success("已解除预警");
    loadReviews();
  } catch (error) {
    if (error !== "cancel") {
      console.error("Resolve warning failed:", error);
      ElMessage.error("操作失败");
    }
  }
};

// 切换评价状态
const handleToggleStatus = async (review) => {
  const newStatus = review.status === "HIDDEN" ? "NORMAL" : "HIDDEN";
  const actionText = newStatus === "HIDDEN" ? "隐藏" : "显示";

  try {
    await ElMessageBox.confirm(`确定要${actionText}这条评价吗？`, "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    await reviewApi.updateReviewStatus(review.id, newStatus);
    ElMessage.success(`${actionText}成功`);
    loadReviews();
  } catch (error) {
    if (error !== "cancel") {
      console.error("Update status failed:", error);
      ElMessage.error(`${actionText}失败`);
    }
  }
};

// 删除评价
const handleDelete = (review) => {
  ElMessageBox.confirm("确定要删除这条评价吗？", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        await reviewApi.deleteReview(review.id);
        ElMessage.success("删除成功");
        loadReviews();
      } catch (error) {
        ElMessage.error("删除失败");
      }
    })
    .catch(() => {});
};

// 分页处理
const handleSizeChange = (val) => {
  pagination.size = val;
  loadReviews();
};

const handleCurrentChange = (val) => {
  pagination.current = val;
  loadReviews();
};

// 导出数据
const exportData = async () => {
  try {
    ElMessage.info("正在生成导出文件...");
    
    const params = {
      orderNumber: searchForm.orderNumber || undefined,
      username: searchForm.username || undefined,
      rating: searchForm.rating || undefined,
      status: searchForm.status || undefined,
    };
    
    if (searchForm.dateRange && searchForm.dateRange[0]) {
      params.startDate = searchForm.dateRange[0] + " 00:00:00";
    }
    if (searchForm.dateRange && searchForm.dateRange[1]) {
      params.endDate = searchForm.dateRange[1] + " 23:59:59";
    }

    const response = await api.get('/api/reviews/export', {
      params,
      responseType: 'blob'
    });

    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    
    const contentDisposition = response.headers['content-disposition'];
    let fileName = `评价列表_${new Date().toISOString().slice(0,10)}.xlsx`;
    if (contentDisposition) {
      const fileNameMatch = contentDisposition.match(/filename\*=utf-8''(.+)/);
      if (fileNameMatch && fileNameMatch.length === 2) {
        fileName = decodeURIComponent(fileNameMatch[1]);
      }
    }
    
    link.setAttribute('download', fileName);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
    
    ElMessage.success("导出成功");
  } catch (error) {
    console.error("导出失败:", error);
    ElMessage.error("导出失败");
  }
};

onMounted(() => {
  if (route.query.status) {
    searchForm.status = route.query.status;
  }
  loadReviews();
});
</script>

<style scoped>
.reviews-container {
  width: 100%;
  margin: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.search-card {
  margin-bottom: 20px;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  margin-bottom: 20px;
}

.stat-content {
  display: flex;
  align-items: center;
  padding: 20px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  color: white;
  font-size: 24px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.dish-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.dish-name {
  font-weight: 500;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  max-height: 60px;
  overflow-y: auto;
}

.review-info {
  max-height: 400px;
  overflow-y: auto;
}

.review-header {
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.review-header h4 {
  margin: 0 0 10px 0;
  color: #333;
}

.review-meta {
  display: flex;
  gap: 20px;
  font-size: 14px;
  color: #666;
}

.review-content {
  margin-bottom: 20px;
}

.review-content p {
  margin: 10px 0;
  line-height: 1.6;
}

.review-images {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
}

.review-img {
  width: 80px;
  height: 80px;
  border-radius: 6px;
}

.review-images-cell {
  position: relative;
  width: 80px;
  height: 48px;
}

.review-img-thumb {
  width: 80px;
  height: 48px;
  border-radius: 6px;
}

.review-img-more {
  position: absolute;
  right: -6px;
  top: -6px;
  background: rgba(0, 0, 0, 0.65);
  color: #fff;
  font-size: 12px;
  padding: 0 6px;
  border-radius: 10px;
  line-height: 20px;
  height: 20px;
}

.image-slot {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  background: #f5f7fa;
  color: #909399;
}

.review-detail-content {
  padding: 0 10px;
}

.mb-20 {
  margin-bottom: 20px;
}

.detail-section {
  margin-bottom: 20px;
}

.detail-section h4 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 16px;
  border-left: 4px solid #409eff;
  padding-left: 10px;
}

.rating-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.rating-item .label {
  margin-right: 10px;
  color: #666;
  width: 40px;
}

.content-box {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 4px;
  color: #606266;
  line-height: 1.6;
}

.reply-box {
  background: #ecf5ff;
  padding: 15px;
  border-radius: 4px;
  color: #409eff;
  line-height: 1.6;
}

.tags-box {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.images-box {
  margin-top: 15px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.detail-img {
  width: 100px;
  height: 100px;
  border-radius: 6px;
  border: 1px solid #eee;
}

:deep(.el-table .warning-row) {
  --el-table-tr-bg-color: var(--el-color-warning-light-9);
}
</style>
