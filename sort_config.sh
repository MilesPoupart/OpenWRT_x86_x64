#!/bin/bash

# 配置文件排序脚本
# 功能：按字母顺序排列配置文件内容，保留特定格式的注释配置，检测并标记冲突

sort_config_file() {
    local input_file="$1"
    local output_file="$2"
    
    if [ ! -f "$input_file" ]; then
        echo "错误: 输入文件 '$input_file' 不存在"
        return 1
    fi
    
    echo "正在处理文件: $input_file"
    echo "输出文件: $output_file"
    
    # 临时文件
    local temp_file=$(mktemp)
    local processed_file=$(mktemp)
    local conflict_check=$(mktemp)
    
    # 处理文件内容
    while IFS= read -r line; do
        # 跳过空行
        if [[ -z "$line" ]]; then
            continue
        fi
        
        # 跳过普通注释行（不是配置注释）
        if [[ "$line" =~ ^#[[:space:]]*[^[:space:]]*$ ]] || [[ "$line" =~ ^#[[:space:]]*$ ]]; then
            continue
        fi
        
        # 处理配置注释行（如 # CONFIG_TARGET_ROOTFS_EXT4FS is not set）
        if [[ "$line" =~ ^#[[:space:]]*CONFIG_ ]]; then
            # 提取配置项名称用于排序
            config_name=$(echo "$line" | sed 's/^#[[:space:]]*//' | sed 's/[[:space:]]*is not set$//' | sed 's/=.*$//')
            echo "${config_name}|${line}" >> "$temp_file"
        # 处理普通配置行
        elif [[ "$line" =~ ^CONFIG_ ]]; then
            # 提取配置项名称用于排序
            config_name=$(echo "$line" | sed 's/=.*$//')
            echo "${config_name}|${line}" >> "$temp_file"
        else
            # 其他行（如普通注释）跳过
            continue
        fi
    done < "$input_file"
    
    # 按配置项名称排序
    sort -t'|' -k1,1 "$temp_file" > "$conflict_check"
    
    # 检测冲突并处理
    local current_config=""
    local current_lines=()
    local has_conflicts=false
    
    while IFS='|' read -r config_name full_line; do
        if [[ "$config_name" == "$current_config" ]]; then
            # 同一配置项，添加到当前行数组
            current_lines+=("$full_line")
        else
            # 新的配置项，处理之前的配置项
            if [[ ${#current_lines[@]} -gt 0 ]]; then
                if [[ ${#current_lines[@]} -gt 1 ]]; then
                    # 检查是否真的有冲突（不同的值）
                    local unique_lines=($(printf '%s\n' "${current_lines[@]}" | sort -u))
                    if [[ ${#unique_lines[@]} -gt 1 ]]; then
                        # 有冲突，添加分割线
                        echo "################ 配置冲突: $current_config ################" >> "$processed_file"
                        printf '%s\n' "${current_lines[@]}" >> "$processed_file"
                        echo "################ 配置冲突结束 ################" >> "$processed_file"
                        has_conflicts=true
                    else
                        # 没有冲突，只是重复，只输出一次
                        echo "${current_lines[0]}" >> "$processed_file"
                    fi
                else
                    # 只有一行，直接输出
                    echo "${current_lines[0]}" >> "$processed_file"
                fi
            fi
            
            # 开始新的配置项
            current_config="$config_name"
            current_lines=("$full_line")
        fi
    done < "$conflict_check"
    
    # 处理最后一个配置项
    if [[ ${#current_lines[@]} -gt 0 ]]; then
        if [[ ${#current_lines[@]} -gt 1 ]]; then
            # 检查是否真的有冲突（不同的值）
            local unique_lines=($(printf '%s\n' "${current_lines[@]}" | sort -u))
            if [[ ${#unique_lines[@]} -gt 1 ]]; then
                # 有冲突，添加分割线
                echo "################ 配置冲突: $current_config ################" >> "$processed_file"
                printf '%s\n' "${current_lines[@]}" >> "$processed_file"
                echo "################ 配置冲突结束 ################" >> "$processed_file"
                has_conflicts=true
            else
                # 没有冲突，只是重复，只输出一次
                echo "${current_lines[0]}" >> "$processed_file"
            fi
        else
            # 只有一行，直接输出
            echo "${current_lines[0]}" >> "$processed_file"
        fi
    fi
    
    # 写入输出文件
    cp "$processed_file" "$output_file"
    
    # 清理临时文件
    rm -f "$temp_file" "$processed_file" "$conflict_check"
    
    echo "处理完成！"
    echo "原文件行数: $(wc -l < "$input_file")"
    echo "输出文件行数: $(wc -l < "$output_file")"
    if [[ "$has_conflicts" == true ]]; then
        echo "⚠️  发现配置冲突！请检查输出文件中的 ################ 标记"
    else
        echo "✅ 未发现配置冲突"
    fi
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        echo "用法: $0 <配置文件1> [配置文件2] ..."
        echo "示例: $0 configs/immortal/immortal.config"
        echo "示例: $0 configs/immortal/immortal.config configs/immortal/merged.config"
        echo ""
        echo "功能: 对配置文件按字母顺序排序，并检测同一文件内的配置冲突"
        echo "      如果发现同一配置项有不同值，将用 ################ 标记分隔"
        exit 1
    fi
    
    # 单文件排序模式
    for config_file in "$@"; do
        if [ -f "$config_file" ]; then
            # 生成输出文件名
            dir_name=$(dirname "$config_file")
            base_name=$(basename "$config_file" .config)
            output_file="${dir_name}/${base_name}_sorted.config"
            
            sort_config_file "$config_file" "$output_file"
            echo "---"
        else
            echo "警告: 文件 '$config_file' 不存在，跳过处理"
        fi
    done
}

# 运行主函数
main "$@"
