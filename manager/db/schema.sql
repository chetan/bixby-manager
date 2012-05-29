SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';


-- -----------------------------------------------------
-- Table `tenants`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tenants` ;

CREATE  TABLE IF NOT EXISTS `tenants` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(255) NULL ,
  `password` CHAR(32) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `orgs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `orgs` ;

CREATE  TABLE IF NOT EXISTS `orgs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `tenant_id` INT UNSIGNED NULL ,
  `name` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  INDEX `fk_orgs_tenants1` (`tenant_id` ASC) ,
  CONSTRAINT `fk_orgs_tenants1`
    FOREIGN KEY (`tenant_id` )
    REFERENCES `tenants` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `hosts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hosts` ;

CREATE  TABLE IF NOT EXISTS `hosts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `org_id` INT UNSIGNED NOT NULL ,
  `ip` VARCHAR(16) NULL ,
  `hostname` VARCHAR(255) NULL ,
  `alias` VARCHAR(255) NULL ,
  `desc` VARCHAR(255) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_hosts_orgs1` (`org_id` ASC) ,
  CONSTRAINT `fk_hosts_orgs1`
    FOREIGN KEY (`org_id` )
    REFERENCES `orgs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agents`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agents` ;

CREATE  TABLE IF NOT EXISTS `agents` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `host_id` INT UNSIGNED NOT NULL ,
  `uuid` VARCHAR(255) NULL ,
  `ip` VARCHAR(16) NULL ,
  `port` SMALLINT UNSIGNED NULL DEFAULT 18000 ,
  `public_key` VARCHAR(426) NULL ,
  `status` SMALLINT UNSIGNED NOT NULL DEFAULT 0 ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  INDEX `fk_agents_hosts1` (`host_id` ASC) ,
  CONSTRAINT `fk_agents_hosts1`
    FOREIGN KEY (`host_id` )
    REFERENCES `hosts` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `users` ;

CREATE  TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `org_id` INT UNSIGNED NOT NULL ,
  `username` VARCHAR(255) NOT NULL ,
  `name` VARCHAR(255) NULL ,
  `email` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_users_orgs1` (`org_id` ASC) ,
  CONSTRAINT `fk_users_orgs1`
    FOREIGN KEY (`org_id` )
    REFERENCES `orgs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `repos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `repos` ;

CREATE  TABLE IF NOT EXISTS `repos` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `org_id` INT UNSIGNED NULL ,
  `name` VARCHAR(255) NULL ,
  `uri` VARCHAR(255) NULL ,
  `branch` VARCHAR(255) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  INDEX `fk_repos_orgs1` (`org_id` ASC) ,
  CONSTRAINT `fk_repos_orgs1`
    FOREIGN KEY (`org_id` )
    REFERENCES `orgs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `commands`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `commands` ;

CREATE  TABLE IF NOT EXISTS `commands` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `repo_id` INT UNSIGNED NULL ,
  `name` VARCHAR(255) NULL ,
  `bundle` VARCHAR(255) NULL ,
  `command` VARCHAR(255) NULL ,
  `options` TEXT NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_commands_repos1` (`repo_id` ASC) ,
  CONSTRAINT `fk_commands_repos1`
    FOREIGN KEY (`repo_id` )
    REFERENCES `repos` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `checks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `checks` ;

CREATE  TABLE IF NOT EXISTS `checks` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `host_id` INT UNSIGNED NOT NULL ,
  `agent_id` INT UNSIGNED NOT NULL ,
  `command_id` INT UNSIGNED NOT NULL ,
  `args` TEXT NULL ,
  `normal_interval` SMALLINT UNSIGNED NULL ,
  `retry_interval` SMALLINT UNSIGNED NULL ,
  `timeout` SMALLINT NULL ,
  `plot` TINYINT(1) NULL ,
  `enabled` TINYINT(1) NULL DEFAULT false ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_checks_agents1` (`agent_id` ASC) ,
  INDEX `fk_checks_commands1` (`command_id` ASC) ,
  CONSTRAINT `fk_checks_agents1`
    FOREIGN KEY (`agent_id` )
    REFERENCES `agents` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_checks_commands1`
    FOREIGN KEY (`command_id` )
    REFERENCES `commands` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `resources`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `resources` ;

CREATE  TABLE IF NOT EXISTS `resources` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `host_id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_resources_hosts1` (`host_id` ASC) ,
  CONSTRAINT `fk_resources_hosts1`
    FOREIGN KEY (`host_id` )
    REFERENCES `hosts` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `metric_infos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `metric_infos` ;

CREATE  TABLE IF NOT EXISTS `metric_infos` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `command_id` INT UNSIGNED NOT NULL ,
  `metric` VARCHAR(255) NOT NULL ,
  `unit` VARCHAR(255) NULL ,
  `desc` VARCHAR(255) NULL ,
  `label` VARCHAR(255) NULL ,
  INDEX `fk_command_keys_commands1` (`command_id` ASC) ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_command_keys_commands1`
    FOREIGN KEY (`command_id` )
    REFERENCES `commands` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `metrics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `metrics` ;

CREATE  TABLE IF NOT EXISTS `metrics` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `check_id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(255) NULL ,
  `key` VARCHAR(255) NOT NULL ,
  `tag_hash` CHAR(32) NOT NULL ,
  `status` SMALLINT UNSIGNED NULL ,
  `last_value` DECIMAL(20,2) NULL ,
  `created_at` DATETIME NOT NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_metrics_checks1` (`check_id` ASC) ,
  CONSTRAINT `fk_metrics_checks1`
    FOREIGN KEY (`check_id` )
    REFERENCES `checks` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `metadata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `metadata` ;

CREATE  TABLE IF NOT EXISTS `metadata` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `key` VARCHAR(255) NOT NULL ,
  `value` VARCHAR(255) NOT NULL ,
  `source` SMALLINT(2) NOT NULL DEFAULT 1 ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `metrics_metadata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `metrics_metadata` ;

CREATE  TABLE IF NOT EXISTS `metrics_metadata` (
  `metric_id` INT UNSIGNED NOT NULL ,
  `metadata_id` INT UNSIGNED NOT NULL ,
  INDEX `fk_metrics_metadata_metrics1` (`metric_id` ASC) ,
  INDEX `fk_metrics_metadata_metadata1` (`metadata_id` ASC) ,
  PRIMARY KEY (`metric_id`, `metadata_id`) ,
  CONSTRAINT `fk_metrics_metadata_metrics1`
    FOREIGN KEY (`metric_id` )
    REFERENCES `metrics` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_metrics_metadata_metadata1`
    FOREIGN KEY (`metadata_id` )
    REFERENCES `metadata` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tags` ;

CREATE  TABLE IF NOT EXISTS `tags` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `taggings`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `taggings` ;

CREATE  TABLE IF NOT EXISTS `taggings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `tag_id` INT UNSIGNED NOT NULL ,
  `taggable_id` INT UNSIGNED NULL ,
  `taggable_type` VARCHAR(255) NULL ,
  `tagger_id` INT UNSIGNED NULL ,
  `tagger_type` VARCHAR(255) NULL ,
  `context` VARCHAR(128) NULL ,
  `created_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_taggings_tags1` (`tag_id` ASC) ,
  INDEX `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id` ASC, `taggable_type` ASC, `context` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  CONSTRAINT `fk_taggings_tags1`
    FOREIGN KEY (`tag_id` )
    REFERENCES `tags` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `hosts_metadata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hosts_metadata` ;

CREATE  TABLE IF NOT EXISTS `hosts_metadata` (
  `host_id` INT UNSIGNED NOT NULL ,
  `metadata_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`host_id`, `metadata_id`) ,
  INDEX `fk_hosts_metadata_hosts1` (`host_id` ASC) ,
  INDEX `fk_hosts_metadata_metadata1` (`metadata_id` ASC) ,
  CONSTRAINT `fk_hosts_metadata_hosts1`
    FOREIGN KEY (`host_id` )
    REFERENCES `hosts` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_hosts_metadata_metadata1`
    FOREIGN KEY (`metadata_id` )
    REFERENCES `metadata` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
